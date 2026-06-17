{
  lib,
  stdenvNoCC,
  requireFile,
  makeWrapper,
  darwin,
  openmpi,
}:

stdenvNoCC.mkDerivation rec {
  pname = "orca";
  version = "6.1.0";

  src = requireFile {
    name = "orca_6_1_0_macosx_arm64_openmpi411.run";
    url = "https://orcaforum.kofo.mpg.de/";
    hash = "sha256-Hha97uNkpRS7GzBMp7QdZ98chHECHV5sHsBzfTfHSa0=";
  };

  nativeBuildInputs = [
    makeWrapper
    darwin.cctools
  ];

  dontUnpack = true;
  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    extract_dir="$TMPDIR/orca-installer"
    mkdir -p "$extract_dir" "$out/lib" "$out/bin"

    sh "$src" \
      --quiet \
      --accept \
      --noprogress \
      --nochown \
      --target "$extract_dir" \
      -- -x -p "$out/lib/orca"

    for prog in "$out/lib/orca"/* "$out/lib/orca/lib"/*; do
      if [ -f "$prog" ]; then
        install_name_tool -change libmpi.40.dylib "${openmpi}/lib/libmpi.40.dylib" "$prog" || true
        install_name_tool -add_rpath "${openmpi}/lib" "$prog" || true
        install_name_tool -add_rpath "$out/lib/orca/lib" "$prog" || true
      fi
    done

    for prog in "$out/lib/orca"/orca "$out/lib/orca"/orca_* "$out/lib/orca"/otool_*; do
      if [ -f "$prog" ] && [ -x "$prog" ]; then
        makeWrapper "$prog" "$out/bin/$(basename "$prog")" \
          --prefix PATH : "$out/lib/orca:${openmpi}/bin" \
          --prefix DYLD_FALLBACK_LIBRARY_PATH : "$out/lib/orca/lib:${openmpi}/lib" \
          --prefix DYLD_LIBRARY_PATH : "$out/lib/orca/lib:${openmpi}/lib" \
          --set ORCA_DIR "$out/lib/orca"
      fi
    done

    runHook postInstall
  '';

  meta = {
    description = "ORCA quantum chemistry package, manually supplied macOS arm64 installer";
    homepage = "https://orcaforum.kofo.mpg.de/";
    license = lib.licenses.unfree;
    platforms = [ "aarch64-darwin" ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
}
