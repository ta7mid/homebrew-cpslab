class CpstestbedGridpack < Formula
  include Language::Python::Virtualenv

  desc "High-performance (HPC) library for simulation of large-scale electrical grids"
  homepage "https://gridpack.pnnl.gov/"
  url "https://github.com/GridOPTICS/GridPACK/archive/refs/heads/develop.tar.gz"
  version "git-develop"
  sha256 "0a351025b73899c3fd4604b7d27291b2ffd103a966bd3751cee33fc50beccf7d"
  license "BSD-2-Clause"

  depends_on "cmake"
  depends_on "open-mpi"
  depends_on "pybind11"
  depends_on "python@3.12"
  depends_on "cpstestbed-boost@1.85"
  depends_on "cpstestbed-globalarrays"
  depends_on "cpstestbed-petsc-complex@3.20"

  patch do
    url "https://github.com/GridOPTICS/GridPACK/compare/develop...fix/mac-build.diff"
    sha256 "f95bdaa1a432dce25029e9b052c62bc22922ceacee741e90957ce4d4fbe47c38"
  end

  patch do
    url "https://github.com/tahmid-khan/GridPACK/compare/bd6a79e4b572efbeef5b9d380d595b4ea4774c3e..32e06444cac1513c7848f71fc7b5704817684800.diff"
    sha256 "18d1d4ef21687cbaf047a6eb22db39d54eed3cce81b97c0be6dd94f4f1412fb8"
  end

  resource "mpi4py" do
    url "https://files.pythonhosted.org/packages/b3/17/1d146e0127b66f1945251f130afac430985d2f9d75a3c0330355f21d876a/mpi4py-3.1.6.tar.gz"
    sha256 "c8fa625e0f92b082ef955bfb52f19fa6691d29273d7d71135d295aa143dee6cb"
  end

  def install
    system "cmake", "-S", "src", "-B", "build",
                    # expanding and modifying `std_cmake_args` to enable debug build:
                    "-D", "CMAKE_INSTALL_PREFIX=#{prefix}",
                    "-D", "CMAKE_INSTALL_LIBDIR=lib",
                    "-D", "CMAKE_BUILD_TYPE=Debug",
                    "-D", "CMAKE_FIND_FRAMEWORK=LAST",
                    "-D", "CMAKE_VERBOSE_MAKEFILE=ON",
                    "-D", "CMAKE_PROJECT_TOP_LEVEL_INCLUDES=#{HOMEBREW_LIBRARY_PATH}/cmake/trap_fetchcontent_provider.cmake",
                    "-Wdev",
                    "-D", "BUILD_TESTING=ON",
                    # library dependencies:
                    "-D", "Boost_ROOT=#{Formula["cpstestbed-boost@1.85"].prefix}",
                    "-D", "GA_DIR=#{Formula["cpstestbed-globalarrays"].prefix}",
                    "-D", "PETSC_DIR=#{Formula["cpstestbed-petsc-complex@3.20"].prefix}",
                    # other arguments:
                    "-D", "CMAKE_CXX_STANDARD=14",
                    "-D", "BUILD_SHARED_LIBS=ON",
                    "-D", "MPIEXEC=mpiexec",
                    "-D", "MPI_C_COMPILER=mpicc",
                    "-D", "MPI_CXX_COMPILER=mpicxx",
                    "-D", "GRIDPACK_TEST_TIMEOUT=50"
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"

    Dir.rmdir "python/pybind11"
    ENV["GRIDPACK_DIR"] = prefix

    venv = virtualenv_create(libexec, "python3.12")
    venv.pip_install resources
    venv.pip_install_and_link buildpath/"python"
  end
end
