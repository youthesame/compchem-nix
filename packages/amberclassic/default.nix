{
  lib,
  stdenv,
  fetchFromGitHub,
  gfortran,
  flex,
  bison,
  rsync,
  makeWrapper,
  tcsh,
}:

stdenv.mkDerivation {
  pname = "amberclassic";
  # Unreleased upstream commit; it updates GAFF2 to 2.2.30.
  version = "2.0-unstable-gaff2.2.30";

  src = fetchFromGitHub {
    owner = "Amber-MD";
    repo = "AmberClassic";
    rev = "919e8b895a4566669325aee14ecf540a5fcb1b89";
    hash = "sha256-5F0q1gD5TcT8enoGQAva90Oh0zLPDe5MV4RQn8Yf3J0=";
  };

  nativeBuildInputs = [
    bison
    flex
    gfortran
    rsync
    makeWrapper
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [ tcsh ];

  postPatch =
    lib.optionalString stdenv.hostPlatform.isLinux ''
      patchShebangs configure
      grep -rlZ /bin/rm configure src | xargs -0 sed -i "s|/bin/rm|rm|g"
    ''
    + ''
    substituteInPlace configure \
      --replace-fail 'enable_sse="--enable-sse2=yes --enable-avx=yes"' 'enable_sse=""'
  '';

  # GCC 15+ defaults to C23, where the bundled NetCDF's `false` enum fails, and
  # GCC 14+ rejects NAB's mismatched pointer types unless -fpermissive.
  env = lib.optionalAttrs stdenv.hostPlatform.isLinux { NIX_CFLAGS_COMPILE = "-std=gnu17 -fpermissive"; };

  configurePhase = ''
    runHook preConfigure

    # With --clang, configure builds fftw without OpenMP but still links
    # -lfftw3_omp; --noopenmp drops it.
    ./configure ${lib.optionalString stdenv.hostPlatform.isDarwin "--clang"} --noboost --noopenmp

    runHook postConfigure
  '';

  buildPhase = ''
    runHook preBuild

    make install

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p "$out"
    cp -R bin lib include dat doc AmberClassic.sh config.h "$out"/

    for prog in "$out"/bin/* "$out"/bin/wrapped_progs/*; do
      if [ -f "$prog" ] && [ -x "$prog" ]; then
        wrapProgram "$prog" \
          --set AMBERCLASSICHOME "$out" \
          --set AMBERHOME "$out" \
          --prefix PATH : "$out/bin" \
          --prefix DYLD_FALLBACK_LIBRARY_PATH : "${gfortran.cc.lib}/lib" \
          --prefix DYLD_LIBRARY_PATH : "${gfortran.cc.lib}/lib" \
          --prefix LD_LIBRARY_PATH : "$out/lib:${gfortran.cc.lib}/lib"
      fi
    done

    runHook postInstall
  '';

  meta = {
    description = "Simplified AmberTools subset including antechamber, sqm, and tleap";
    homepage = "https://github.com/Amber-MD/AmberClassic";
    license = lib.licenses.gpl2Plus;
    platforms = [
      "aarch64-darwin"
      "x86_64-linux"
    ];
  };
}
