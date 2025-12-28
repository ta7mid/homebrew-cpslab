class Helics < Formula
  desc "Hierarchical Engine for Large-scale Infrastructure Co-Simulation"
  homepage "https://helics.org/"
  url "https://github.com/GMLC-TDC/HELICS/releases/download/v3.5.3/Helics-v3.5.3-source.tar.gz"
  sha256 "f9ace240510b18caf642f55d08f9009a9babb203fbc032ec7d7d8aa6fd5e1553"
  license "BSD-3-Clause"

  depends_on "cmake" => :build
  depends_on "fmt"
  depends_on "zeromq"

  keg_only "it conflicts with `fmt`"

  def install
    system "cmake", "-B", "build", *std_cmake_args, "-DCMAKE_BUILD_TYPE=Debug"
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"
  end
end
