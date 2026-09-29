{
  lib,
  stdenvNoCC,
  requireFile,
  makeWrapper,
  openmpi,
}:

stdenvNoCC.mkDerivation rec {
  pname = "orca";
  version = "6.1.1";

  src = requireFile {
    name = "orca_6_1_1_macosx_arm64_openmpi411.run";
    url = "https://orcaforum.kofo.mpg.de/";
    hash = "sha256-D7e00ZlK9UGChjc+LJLaQeOl1ks1Q42PXG+y4CQnFKw=";
  };

  nativeBuildInputs = [
    makeWrapper
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

    # The vendor binaries lack Mach-O headerpad space, so install_name_tool
    # cannot rewrite the bare libmpi.40.dylib reference. Bundled liborca_*
    # resolve via the shipped LC_RPATH @loader_path/lib; libmpi resolves via
    # the DYLD_* variables set in the wrappers below.
    for prog in "$out/lib/orca"/orca "$out/lib/orca"/orca_* "$out/lib/orca"/otool_*; do
      if [ -f "$prog" ] && [ -x "$prog" ]; then
        makeWrapper "$prog" "$out/bin/$(basename "$prog")" \
          --prefix PATH : "$out/lib/orca:${openmpi}/bin" \
          --prefix DYLD_FALLBACK_LIBRARY_PATH : "$out/lib/orca/lib:${openmpi}/lib" \
          --prefix DYLD_LIBRARY_PATH : "$out/lib/orca/lib:${openmpi}/lib" \
          --set OMPI_MCA_mca_base_env_list "DYLD_LIBRARY_PATH=$out/lib/orca/lib:${openmpi}/lib;DYLD_FALLBACK_LIBRARY_PATH=$out/lib/orca/lib:${openmpi}/lib;PATH;ORCA_DIR" \
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
