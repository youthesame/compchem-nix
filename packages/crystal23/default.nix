{
  lib,
  stdenvNoCC,
  requireFile,
  makeWrapper,
  tcsh,
  openmpi,
  gccFortran,
}:

stdenvNoCC.mkDerivation rec {
  pname = "crystal23";
  version = "23-v1.0.1";

  exeSrc = requireFile {
    name = "crystal23_v1_0_1_MacOsX-gnu12.1_openmpi4.1.1_exe.tar.gz";
    url = "https://www.crystal.unito.it/";
    hash = "sha256-sBzgA2oyuvhpXNmvG3fI2MUQMFgbvw31WrmDXe1u+cU=";
  };

  utilsSrc = requireFile {
    name = "utils23.tar.gz";
    url = "https://www.crystal.unito.it/";
    hash = "sha256-bkUVLnoVYbiVlCV8Wx2xJlBa6qAoLkrAn8QeR4qdsyg=";
  };

  nativeBuildInputs = [
    makeWrapper
  ];

  dontUnpack = true;
  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    root="$out/lib/CRYSTAL23"
    mkdir -p "$root/bin/MacOsx_ARM-gfortran" "$out/bin"

    tar -xzf "$exeSrc" -C "$TMPDIR"
    cp -R "$TMPDIR"/crystal23_v1_0_1_MacOsX-gnu_12.1_openmpi4.1.1_exe/v1.0.1 \
      "$root/bin/MacOsx_ARM-gfortran/"

    tar -xzf "$utilsSrc" -C "$root"
    chmod -R u+w "$root"
    chmod +x "$root"/utils23/run* "$root"/bin/MacOsx_ARM-gfortran/v1.0.1/*

    for prog in crystal Pcrystal properties Pproperties; do
      makeWrapper "$root/bin/MacOsx_ARM-gfortran/v1.0.1/$prog" "$out/bin/$prog" \
        --set CRY23_ROOT "$root" \
        --set CRY23_ARCH "MacOsx_ARM-gfortran" \
        --set VERSION "v1.0.1" \
        --prefix PATH : "$root/bin/MacOsx_ARM-gfortran/v1.0.1:$root/utils23:${openmpi}/bin" \
        --prefix DYLD_FALLBACK_LIBRARY_PATH : "${gccFortran.cc.lib}/lib:${openmpi}/lib"
    done

    for script in "$root"/utils23/run*; do
      makeWrapper "$script" "$out/bin/$(basename "$script")" \
        --set CRY23_ROOT "$root" \
        --set CRY23_BIN "bin" \
        --set CRY23_ARCH "MacOsx_ARM-gfortran" \
        --set VERSION "v1.0.1" \
        --set CRY23_EXEDIR "$root/bin/MacOsx_ARM-gfortran" \
        --set CRY23_UTILS "$root/utils23" \
        --set-default CRY23_SCRDIR "/tmp" \
        --prefix PATH : "$root/bin/MacOsx_ARM-gfortran/v1.0.1:$root/utils23:${openmpi}/bin:${tcsh}/bin" \
        --prefix DYLD_FALLBACK_LIBRARY_PATH : "${gccFortran.cc.lib}/lib:${openmpi}/lib"
    done

    runHook postInstall
  '';

  meta = {
    description = "CRYSTAL23 quantum chemistry package, manually supplied macOS arm64 binaries";
    homepage = "https://www.crystal.unito.it/";
    license = lib.licenses.unfree;
    platforms = [ "aarch64-darwin" ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
}
