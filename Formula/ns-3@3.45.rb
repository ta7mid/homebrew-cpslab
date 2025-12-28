class Ns3AT345 < Formula
  desc "Discrete-event network simulator"
  homepage "https://www.nsnam.org/"
  url "https://gitlab.com/nsnam/ns-3-dev/-/archive/ns-3.45/ns-3-dev-ns-3.45.tar.gz"
  sha256 "ea736ba7de4baf0b4fc91cfe2ff74ac3bcd94d4e3ad7055141ddbb30f8d0fc48"
  license "GPL-2.0-only"

  depends_on "boost" => :build
  depends_on "cmake" => :build
  depends_on "lld" => :build

  uses_from_macos "libxml2"
  uses_from_macos "sqlite"

  def install
    # Fix to error: no matching function for call to ‘find...’
    # Issue ref: https://gitlab.com/nsnam/ns-3-dev/-/issues/1264
    inreplace "src/core/model/test.cc", "#include <vector>", "#include <vector>\n#include <algorithm>"

    enabled_modules = %w[
      applications
      bridge
      core
      csma
      internet
      internet-apps
      network
      point-to-point
      topology-read
    ]

    # Fix binding's rpath
    linker_flags = "-Wl,-rpath,#{loader_path}"

    args = %W[
      -D CMAKE_SHARED_LINKER_FLAGS=#{linker_flags}
      -D NS3_CCACHE=OFF
      -D NS3_CLANG_TIDY=OFF
      -D NS3_COVERAGE=OFF
      -D NS3_DPDK=OFF
      -D NS3_EIGEN=OFF
      -D NS3_ENABLED_MODULES=#{enabled_modules.join(";")}
      -D NS3_ENABLE_BUILD_VERSION=OFF
      -D NS3_ENABLE_SUDO=OFF
      -D NS3_EXAMPLES=OFF
      -D NS3_GSL=OFF
      -D NS3_GTK3=OFF
      -D NS3_MONOLIB=OFF
      -D NS3_MPI=OFF
      -D NS3_NINJA_TRACING=OFF
      -D NS3_PRECOMPILE_HEADERS=OFF
      -D NS3_PYTHON_BINDINGS=OFF
      -D NS3_SQLITE=OFF
      -D NS3_TESTS=OFF
      -D NS3_VISUALIZER=OFF
      -D NS3_WARNINGS=OFF
    ]

    # Avoid error about `-fsanitize=leak` being unsupported for arm64-apple-darwin
    args << "-D NS3_SANITIZE=ON" if !OS.mac? || !Hardware::CPU.arm?

    system "cmake", "-S", ".", "-B", "build", *args, *std_cmake_args, "-D CMAKE_BUILD_TYPE=debug"
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"

    pkgshare.install "examples"
  end

  test do
    flags = %W[
      -I#{include}
      -L#{lib}
      -lns#{version}-core-debug
      -lns#{version}-network-debug
      -lns#{version}-internet-debug
      -lns#{version}-point-to-point-debug
      -lns#{version}-applications-debug
    ]
    system ENV.cxx, "-std=c++20", "-o", "test", pkgshare/"examples/tutorial/first.cc", *flags
    system "./test"
  end
end
