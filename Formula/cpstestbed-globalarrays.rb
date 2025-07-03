class CpstestbedGlobalarrays < Formula
  desc "Partitioned Global Address Space (PGAS) library for distributed arrays"
  homepage "http://hpc.pnl.gov/globalarrays/"
  url "https://github.com/GlobalArrays/ga/releases/download/v5.9.2/ga-5.9.2.tar.gz"
  sha256 "cbf15764bf9c04e47e7a798271c418f76b23f1857b23feb24b6cb3891a57fbf2"
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
                          "MPICC=#{Formula['open-mpi'].opt_prefix}/bin/mpicc",
                          "MPIFC=#{Formula['open-mpi'].opt_prefix}/bin/mpif90",
                          "MPIF77=#{Formula['open-mpi'].opt_prefix}/bin/mpif77",
                          "MPIF99=#{Formula['open-mpi'].opt_prefix}/bin/mpif99",
                          "MPICXX=#{Formula['open-mpi'].opt_prefix}/bin/mpicxx",
                          "MPIEXEC=#{Formula['open-mpi'].opt_prefix}/bin/mpiexec",
                          "MPIRUN=#{Formula['open-mpi'].opt_prefix}/bin/mpirun",
                          "MAKEFLAGS=$MAKEFLAGS"
    system "make"
    system "make", "install"
  end
end
