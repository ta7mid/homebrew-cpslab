class CpstestbedPetscComplex < Formula
  desc "Portable, Extensible Toolkit for Scientific Computation (complex)"
  homepage "https://petsc.org/"
  url "https://web.cels.anl.gov/projects/petsc/download/release-snapshots/petsc-3.22.0.tar.gz"
  sha256 "2c03f7c0f7ad2649240d4989355cf7fb7f211b75156cd7d424e1d9dd7dfb290b"
  license "BSD-2-Clause"

  livecheck do
    formula "petsc-complex"
  end

  depends_on "brewsci/num/brewsci-parmetis"
  depends_on "brewsci/num/brewsci-superlu-dist"
  depends_on "cmake"
  depends_on "hdf5-mpi"
  depends_on "hwloc"
  depends_on "metis"
  depends_on "open-mpi"
  depends_on "openblas"
  depends_on "scalapack"
  depends_on "suite-sparse"

  uses_from_macos "python" => :build

  keg_only "PETSc is provided by Homebrew Core"

  def install
    system "./configure", "--prefix=#{prefix}",
                          "--with-cmake",
                          "--with-metis-dir=#{Formula["metis"].prefix}",
                          "--with-parmetis-dir=#{Formula["brewsci-parmetis"].prefix}",
                          "--with-suitesparse-dir=#{Formula["suite-sparse"].prefix}",
                          "--with-superlu_dist-dir=#{Formula["brewsci-superlu-dist"].prefix}",
                          "--with-debugging",
                          "--with-scalar-type=complex",
                          "--with-x=0",
                          "--CC=mpicc",
                          "--CXX=mpicxx",
                          "--F77=mpif77",
                          "--FC=mpif90",
                          "MAKEFLAGS=$MAKEFLAGS"

    # Avoid references to Homebrew shims (perform replacement before running `make`, or else the shim
    # paths will still end up in compiled code)
    inreplace "arch-#{OS.kernel_name.downcase}-c-debug/include/petscconf.h", "#{Superenv.shims_path}/", ""

    system "make", "all"
    system "make", "install"

    # Avoid references to Homebrew shims
    rm(lib/"petsc/conf/configure-hash")

    if OS.mac? || File.foreach("#{lib}/petsc/conf/petscvariables").any? { |l| l[Superenv.shims_path.to_s] }
      inreplace lib/"petsc/conf/petscvariables", "#{Superenv.shims_path}/", ""
    end
  end

  test do
    flags = %W[-I#{include} -L#{lib} -lpetsc]
    flags << "-Wl,-rpath,#{lib}" if OS.linux?
    system "mpicc", share/"petsc/examples/src/ksp/ksp/tutorials/ex1.c", "-o", "test", *flags
    output = shell_output("./test")
    # This PETSc example prints several lines of output. The last line contains
    # an error norm, expected to be small.
    line = output.lines.last
    assert_match(/^Norm of error .+, Iterations/, line, "Unexpected output format")
    error = line.split[3].to_f
    assert (error >= 0.0 && error < 1.0e-13), "Error norm too large"
  end
end
