class CpstestbedHelics < Formula
  desc "Hierarchical Engine for Large-scale Infrastructure Co-Simulation"
  homepage "https://helics.org/"
  url "https://github.com/GMLC-TDC/HELICS/releases/download/v3.5.3/Helics-v3.5.3-source.tar.gz"
  sha256 "f9ace240510b18caf642f55d08f9009a9babb203fbc032ec7d7d8aa6fd5e1553"
  license "BSD-3-Clause"

  livecheck do
    url :url
    strategy :github_latest
  end

  depends_on "cmake" => :build
  depends_on "cpstestbed-boost@1.85"
  depends_on "zeromq"

  keg_only "it conflicts with `fmt`"

  def install
    system "cmake", "-B", "build",
      # expanding and modifying `std_cmake_args` to enable debug build:
      "-D", "CMAKE_INSTALL_PREFIX=#{prefix}",
      "-D", "CMAKE_INSTALL_LIBDIR=lib",
      "-D", "CMAKE_BUILD_TYPE=Debug",
      "-D", "CMAKE_FIND_FRAMEWORK=LAST",
      "-D", "CMAKE_VERBOSE_MAKEFILE=ON",
      "-D", "CMAKE_PROJECT_TOP_LEVEL_INCLUDES=#{HOMEBREW_LIBRARY_PATH}/cmake/trap_fetchcontent_provider.cmake",
      "-Wdev",
      "-D", "BUILD_TESTING=ON",
      # others:
      "-D", "Boost_ROOT=#{Formula["cpstestbed-boost@1.85"].prefix}",
      "-D", "BUILD_SHARED_LIBS=ON"

    system "cmake", "--build", "build"
    system "cmake", "--install", "build"
  end
end
