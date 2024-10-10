class CpstestbedGlobalarrays < Formula
  desc "Partitioned Global Address Space (PGAS) library for distributed arrays"
  homepage "http://hpc.pnl.gov/globalarrays/"
  url "https://github.com/GlobalArrays/ga/releases/download/v5.8/ga-5.8.tar.gz"
  sha256 "64df7d1ea4053d24d84ca361e67a6f51c7b17ed7d626cb18a9fbc759f4a078ac"
  license "BSD-3-Clause"

  livecheck do
    url :url
    strategy :github_latest
  end

  depends_on "cmake" => :build
  depends_on "gcc"
  depends_on "open-mpi"

  def install
    system "./configure", "--disable-silent-rules",

                          # expanding and modifying `std_configure_args`:
                          "--enable-debug",
                          "--disable-dependency-tracking",
                          "--prefix=#{prefix}",
                          "--libdir=#{lib}",

                          "--with-mpi-ts",
                          "--enable-cxx",
                          "--enable-shared",
                          "MPICC=mpicc",
                          "MPIFC=mpif90",
                          "MPIF77=mpif77",
                          "MPIF99=mpif99",
                          "MPICXX=mpicxx",
                          "MPIEXEC=mpiexec",
                          "MPIRUN=mpirun",
                          "MAKEFLAGS=$MAKEFLAGS"
    system "make"
    system "make", "install"
  end
end
