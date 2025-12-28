class Gridpack < Formula
  desc "HPC package for simulation of large-scale electrical grids"
  homepage "https://github.com/GridOPTICS/GridPACK"
  url "https://github.com/GridOPTICS/GridPACK/releases/download/v3.5/GridPACK-3.5.tar.gz"
  sha256 "73b109506ff311eea55805af915f3186337a9001053ae97333f9760842d75a22"
  license "BSD-2-Clause"

  depends_on "cmake" => [:build, :test]
  depends_on "boost"
  depends_on "boost-mpi"
  depends_on "global-arrays"
  depends_on "open-mpi"
  depends_on "ta7mid/cpslab/petsc"

  def install
    # Boost.System is header-only now
    inreplace "src/CMakeLists.txt", "mpi serialization random system", "mpi serialization random"

    args = %W[
      -D GRIDPACK_ENABLE_TESTS=NO
      -D ENABLE_ENVIRONMENT_FROM_COMM=ON
      -D GA_DIR=#{Formula["global-arrays"].opt_prefix}
      -D PETSC_DIR=#{Formula["ta7mid/cpslab/petsc"].opt_prefix}
    ]

    system "cmake", "-S", "src", "-B", "build", *args, *std_cmake_args, "-DCMAKE_BUILD_TYPE=Debug"
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"
    (lib/"cmake").install lib/"GridPACK.cmake"
  end

  test do
    (testpath/"CMakeLists.txt").write <<~CMAKE
      cmake_minimum_required(VERSION 3.10)
      project(gridpack_test CXX)

      include("#{lib}/cmake/GridPACK.cmake")
      gridpack_setup()

      add_executable(test test.c++)
      target_compile_definitions(test PRIVATE ${GRIDPACK_DEFINITIONS})
      target_include_directories(test PRIVATE ${GRIDPACK_INCLUDE_DIRS})
      target_link_libraries(test PRIVATE ${GRIDPACK_LIBS})
    CMAKE

    (testpath/"test.c++").write <<~CPP
      #include <gridpack/environment/environment.hpp>
      #include <cstdlib>

      int main(int argc, char* argv[])
      {
        gridpack::Environment env {argc, argv};
        return env.active() ? EXIT_SUCCESS : EXIT_FAILURE;
      }
    CPP

    system "cmake", "."
    system "cmake", "--build", "."
    output = shell_output("mpirun -n 3 ./test")
    assert_equal "GridPACK math module configured on 3 processors", output.strip
  end
end
