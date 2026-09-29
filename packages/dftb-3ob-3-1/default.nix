{ lib, stdenvNoCC, fetchurl }:

stdenvNoCC.mkDerivation {
  pname = "dftb-3ob-3-1";
  version = "3.1.0";

  src = fetchurl {
    url = "https://github.com/dftbparams/3ob/releases/download/v3.1.0/3ob-3-1.tar.xz";
    hash = "sha256-isGU9OY3WWGWn53mLsbvG6we6DI8f9zkxzeWihnIGic=";
  };

  installPhase = ''
    runHook preInstall
    mkdir -p "$out/share/slakos/3ob-3-1"
    cp -R ./. "$out/share/slakos/3ob-3-1/"
    runHook postInstall
  '';

  meta = {
    description = "3ob-3-1 Slater-Koster parameters for DFTB3";
    homepage = "https://github.com/dftbparams/3ob";
    license = lib.licenses.cc-by-sa-40;
    platforms = lib.platforms.all;
  };
}
