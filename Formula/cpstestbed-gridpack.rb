class CpstestbedGridpack < Formula
  include Language::Python::Virtualenv

  desc "High-performance (HPC) library for simulation of large-scale electrical grids"
  homepage "https://gridpack.pnnl.gov/"
  url "https://github.com/cpslab-nsu/GridPACK/archive/refs/heads/master.tar.gz"
  version "HEAD"
  sha256 "90faaea85a27b4e365725b7b97775f1fb550dcdd4596a24c1ce0c16d4cb5297f"
  license "BSD-2-Clause"

  depends_on "cmake"
  depends_on "open-mpi"
  depends_on "pybind11"
  depends_on "python@3.12"
  depends_on "cpstestbed-boost@1.85"
  depends_on "cpstestbed-globalarrays"
  depends_on "cpstestbed-petsc-complex@3.20"

  resource "mpi4py" do
    url "https://files.pythonhosted.org/packages/b3/17/1d146e0127b66f1945251f130afac430985d2f9d75a3c0330355f21d876a/mpi4py-3.1.6.tar.gz"
    sha256 "c8fa625e0f92b082ef955bfb52f19fa6691d29273d7d71135d295aa143dee6cb"
  end

  def install
    # override `std_cmake_args` to enable debug build
    std_cmake_args = %W[
      -D CMAKE_INSTALL_PREFIX=#{prefix}
      -D CMAKE_INSTALL_LIBDIR=lib
      -D CMAKE_BUILD_TYPE=Debug
      -D CMAKE_FIND_FRAMEWORK=LAST
      -D CMAKE_VERBOSE_MAKEFILE=ON
      -D CMAKE_PROJECT_TOP_LEVEL_INCLUDES=#{HOMEBREW_LIBRARY_PATH}/cmake/trap_fetchcontent_provider.cmake
      -Wdev
      -D BUILD_TESTING=ON
    ]

    ENV["BOOST_DIR"] = Formula["cpstestbed-boost@1.85"].prefix
    cmake_args = %W[
      -D GA_DIR=#{Formula["cpstestbed-globalarrays"].prefix}
      -D PETSC_DIR=#{Formula["cpstestbed-petsc-complex@3.20"].prefix}
      -D ENABLE_ENVIRONMENT_FROM_COMM=OFF
      -D CMAKE_CXX_STANDARD=14
      -D BUILD_SHARED_LIBS=ON
      -D MPIEXEC=mpiexec
      -D MPI_C_COMPILER=mpicc
      -D MPI_CXX_COMPILER=mpicxx
      -D GRIDPACK_TEST_TIMEOUT=30
    ]

    system "cmake", "-S", "src", "-B", "build", *cmake_args, *std_cmake_args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"

    Dir.rmdir "python/pybind11"
    ENV["GRIDPACK_DIR"] = prefix

    venv = virtualenv_create(libexec, "python3.12")
    venv.pip_install resources
    venv.pip_install_and_link buildpath/"python"
  end
end
