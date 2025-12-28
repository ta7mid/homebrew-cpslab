class GlobalArrays < Formula
  desc "Partitioned Global Address Space (PGAS) library for distributed arrays"
  homepage "https://globalarrays.github.io/"
  url "https://github.com/GlobalArrays/ga/releases/download/v5.9.2/ga-5.9.2.tar.gz"
  sha256 "cbf15764bf9c04e47e7a798271c418f76b23f1857b23feb24b6cb3891a57fbf2"
  license "BSD-3-Clause"

  depends_on "cmake" => :build
  depends_on "open-mpi"

  def install
    inreplace "CMakeLists.txt", "install(TARGETS ga\n", "install(TARGETS ga ga++\n"
    inreplace "ga++/CMakeLists.txt", "target_link_libraries(ga++)", "target_link_libraries(ga++ PUBLIC ga)"

    args = %w[
      -D ENABLE_TESTS=OFF
      -D ENABLE_FORTRAN=OFF
    ]
    system "cmake", "-S", ".", "-B", "build", *args, *std_cmake_args, "-D CMAKE_BUILD_TYPE=Debug"
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"
  end

  test do
    (testpath/"test.c++").write <<~CXX
      #include <ga/ga++.h>
      #include <iostream>

      int main(int argc, char* argv[])
      {
        GA::Initialize(argc, argv);
        if (GA::nodeid() == 0)
          std::cout << GA::nodes();
        GA::Terminate();
      }
    CXX

    flags = %W[-I#{include} -L#{lib} -Wl,-rpath,#{lib} -lga -lga++]
    system "mpicxx", "test.c++", "-o", "test", *flags
    output = shell_output("mpirun ./test")
    assert_equal Hardware::CPU.cores, output.to_i
  end
end
