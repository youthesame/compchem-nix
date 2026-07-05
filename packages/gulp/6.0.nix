{
  lib,
  stdenv,
  requireFile,
  gfortran,
  makeWrapper,
  openmpi,
  scalapack,
}:

stdenv.mkDerivation rec {
  pname = "gulp-mpi";
  version = "6.0";

  src = requireFile {
    name = "gulp-6.0.tgz";
    url = "https://gulp.curtin.edu.au/gulp/";
    hash = "sha256-9zsPaMi6SZ4/nw0N5eOzQwfguFeTh6TLK5zf0c9i6dE=";
  };

  nativeBuildInputs = [
    gfortran
    makeWrapper
    (openmpi.dev or openmpi)
  ];

  buildInputs = [
    openmpi
    scalapack
  ];

  postPatch = ''
    patchShebangs Src/mkgulp

    substituteInPlace Src/mkgulp \
      --replace-fail "echo 'RUNF90=mpif90 ' >> makefile" "echo 'RUNF90=mpif90 -fallow-argument-mismatch ' >> makefile" \
      --replace-fail "echo 'RUNCC=mpif90 ' >> makefile" "echo 'RUNCC=mpicc ' >> makefile" \
      --replace-fail "echo 'SLIBS=-L/opt/local/lib -lscalapack ' >> makefile" "echo 'SLIBS=-L${scalapack}/lib -lscalapack ' >> makefile" \
      --replace-fail "echo 'OPT=-O3 -ffpe-summary=invalid,zero,overflow ' >> makefile" "echo 'OPT=-O3 -ffree-line-length-none -ffpe-summary=invalid,zero,overflow ' >> makefile" \
      --replace-fail "echo 'OPT2=-O2 -ffpe-summary=invalid,zero,overflow ' >> makefile" "echo 'OPT2=-O0 -ffpe-summary=invalid,zero,overflow ' >> makefile" \
      --replace-fail "echo 'OPT1=-O1 -ffpe-summary=invalid,zero,overflow ' >> makefile" "echo 'OPT1=-O0 -ffpe-summary=invalid,zero,overflow ' >> makefile"

    substituteInPlace Src/mkgulp \
      --replace-fail "-ffpe-summary=invalid,zero,overflow " ""
  '';

  buildPhase = ''
    runHook preBuild

    cd Src
    ./mkgulp -m -j 1
    cd ..

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    install -Dm755 Src/gulp "$out/bin/gulp"
    mkdir -p "$out/share/gulp"
    cp -R Docs Examples Libraries "$out/share/gulp/"

    wrapProgram "$out/bin/gulp" \
      --set GULP_ROOT "$out/share/gulp" \
      --set GULP_LIB "$out/share/gulp/Libraries" \
      --set GULP_DOC "$out/share/gulp/Docs" \
      --prefix PATH : "${openmpi}/bin"

    runHook postInstall
  '';

  meta = {
    description = "GULP molecular simulation code built with MPI support";
    homepage = "https://gulp.curtin.edu.au/gulp/";
    license = lib.licenses.unfree;
    mainProgram = "gulp";
    platforms = [ "aarch64-darwin" ];
  };
}
