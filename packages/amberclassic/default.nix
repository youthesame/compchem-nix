{
  lib,
  stdenv,
  fetchFromGitHub,
  gfortran,
  flex,
  bison,
  rsync,
  makeWrapper,
}:

stdenv.mkDerivation rec {
  pname = "amberclassic";
  version = "2.0";

  src = fetchFromGitHub {
    owner = "Amber-MD";
    repo = "AmberClassic";
    rev = "v${version}";
    hash = "sha256-xhDWyEXnKBroTVVLe4TdU6OpxskLpXBqJvfJjbwv06A=";
  };

  nativeBuildInputs = [
    bison
    flex
    gfortran
    rsync
    makeWrapper
  ];

  postPatch = ''
    substituteInPlace configure \
      --replace-fail 'enable_sse="--enable-sse2=yes --enable-avx=yes"' 'enable_sse=""'
  '';

  configurePhase = ''
    runHook preConfigure

    ./configure --clang --noboost

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
