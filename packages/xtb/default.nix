{
  lib,
  stdenv,
  fetchurl,
  meson,
  ninja,
  pkg-config,
  python3,
  gfortran,
  makeWrapper,
  llvmPackages,
  openblas,
  mctc-lib,
  multicharge,
  dftd4,
  test-drive,
}:

stdenv.mkDerivation rec {
  pname = "xtb";
  version = "6.7.1";

  src = fetchurl {
    url = "https://github.com/grimme-lab/xtb/releases/download/v${version}/xtb-${version}-source.tar.xz";
    hash = "sha256-eaKi9QCRs7lB5ROcGzilMgPV0um6SWp61QXYwxzNYBM=";
  };

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    python3
    gfortran
    makeWrapper
  ];

  buildInputs = lib.optionals stdenv.hostPlatform.isDarwin [ llvmPackages.openmp ] ++ [
    openblas
    mctc-lib
    multicharge
    dftd4
    test-drive
  ];

  mesonFlags = [
    "-Dlapack=openblas"
    "-Dtblite=disabled"
    "-Dcpcmx=disabled"
    "-Dopenmp=true"
  ];

  # Newer meson compiles the xtb executable before the library modules it
  # uses exist; build the libraries first.
  preBuild = ''
    ninja -j$NIX_BUILD_CORES libxtb.a ${
      if stdenv.hostPlatform.isDarwin then "libxtb.6.dylib" else "libxtb.so.6.7.0"
    }
  '';

  postInstall = ''
    wrapProgram "$out/bin/xtb" \
      --set XTBPATH "$out/share/xtb"
  '';

  meta = {
    description = "Semiempirical Extended Tight-Binding Program Package";
    homepage = "https://github.com/grimme-lab/xtb";
    license = lib.licenses.lgpl3Plus;
    platforms = [ "aarch64-darwin" "x86_64-linux" ];
  };
}
