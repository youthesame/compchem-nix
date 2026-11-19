{
  lib,
  stdenv,
  fetchurl,
  distfiles,
  autoPatchelfHook,
  makeWrapper,
  openmpi,
  openssh,
}:

# Layout follows NixOS-QChem's orca package.
stdenv.mkDerivation {
  pname = "orca";
  version = "6.1.1";

  src = fetchurl {
    url = "file://${distfiles}/orca/6.1.1/orca_6_1_1_linux_x86-64_shared_openmpi418_avx2.tar.xz";
    hash = "sha256-Xq9nb5cRo4g11gkmQyGjAma0h7ZUd1R4At7e6YK8gtU=";
  };

  nativeBuildInputs = [
    autoPatchelfHook
    makeWrapper
  ];
  buildInputs = [
    openmpi
    stdenv.cc.cc.lib
  ];

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib/orca $out/bin
    cp -R . $out/lib/orca/
    for prog in $out/lib/orca/orca $out/lib/orca/orca_* $out/lib/orca/otool_*; do
      if [ -f "$prog" ] && [ -x "$prog" ]; then
        makeWrapper "$prog" "$out/bin/$(basename "$prog")" \
          --prefix PATH : "$out/lib/orca:${lib.getBin openmpi}/bin:${lib.getBin openssh}/bin" \
          --set ORCA_DIR "$out/lib/orca"
      fi
    done

    runHook postInstall
  '';

  passthru.mpi = openmpi;

  meta = {
    description = "ORCA quantum chemistry package, manually supplied Linux x86-64 AVX2 binaries";
    homepage = "https://orcaforum.kofo.mpg.de/";
    license = lib.licenses.unfree;
    platforms = [ "x86_64-linux" ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
}
