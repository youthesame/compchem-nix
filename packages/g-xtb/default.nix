{
  lib,
  stdenvNoCC,
  fetchurl,
  makeWrapper,
  gccFortran,
}:

stdenvNoCC.mkDerivation rec {
  pname = "g-xtb";
  version = "2.0.1";

  src = fetchurl {
    url = "https://github.com/grimme-lab/g-xtb/releases/download/v${version}/xtb-6.7.1-gxtb-140526-macos-arm64.tar.gz";
    hash = "sha256-A1o38kGiQGfrhUF36g3T4dG0isohVc+TSq4xU1HgmK8=";
  };

  nativeBuildInputs = [
    makeWrapper
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p "$out"
    cp -R . "$out/"

    for prog in "$out/bin"/* "$out/lib"/*.dylib; do
      if [ -f "$prog" ]; then
        install_name_tool -add_rpath "${gccFortran.cc.lib}/lib" "$prog" || true
      fi
    done

    for prog in "$out/bin"/*; do
      if [ -f "$prog" ] && [ -x "$prog" ]; then
        mv "$prog" "$prog-wrapped"
        makeWrapper "$prog-wrapped" "$prog" \
          --set GXTB_ROOT "$out" \
          --set XTBPATH "$out/share/xtb" \
          --prefix PATH : "$out/bin" \
          --prefix DYLD_FALLBACK_LIBRARY_PATH : "${gccFortran.cc.lib}/lib" \
          --prefix DYLD_LIBRARY_PATH : "${gccFortran.cc.lib}/lib"
      fi
    done

    runHook postInstall
  '';

  meta = {
    description = "g-xTB preview release bundled with xTB";
    homepage = "https://github.com/grimme-lab/g-xtb";
    license = lib.licenses.lgpl3Plus;
    platforms = [ "aarch64-darwin" ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
}
