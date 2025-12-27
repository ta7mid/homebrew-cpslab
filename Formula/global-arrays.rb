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

    args = ["-DENABLE_TESTS=OFF", "-DENABLE_FORTRAN=OFF"]
    system "cmake", "-S", ".", "-B", "build", *args, *std_cmake_args, "-DCMAKE_BUILD_TYPE=Debug"
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"
  end

  test do
    (testpath/"test.c++").write <<~CPP
      #include <ga/ga++.h>
      #include <iostream>

      int main(int argc, char* argv[])
      {
        GA::Initialize(argc, argv);
        if (GA::nodeid() == 0)
          std::cout << GA::nodes();
        GA::Terminate();
      }
    CPP
    system "mpicxx", "test.c++", "-o", "test", "-I#{include}", "-L#{lib}", "-lga", "-lga++"
    output = shell_output("mpirun ./test")
    assert_equal Hardware::CPU.cores, output.to_i
  end
end
