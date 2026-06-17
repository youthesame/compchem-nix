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

  buildInputs = [
    llvmPackages.openmp
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
