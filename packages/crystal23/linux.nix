{
  lib,
  stdenv,
  fetchurl,
  distfiles,
  autoPatchelfHook,
  makeWrapper,
  tcsh,
  openmpi,
  llvmPackages,
}:

stdenv.mkDerivation {
  pname = "crystal23";
  version = "23-v1.0.1";

  exeSrc = fetchurl {
    url = "file://${distfiles}/crystal23/23-v1.0.1/crystal23_v1_0_1_Linux-ifort21.4_openmpi4.1.1_omp_exe.tar.gz";
    hash = "sha256-TmSs+7sgNDX78CiCiljwJo8ZCntMScQZtHyxcuL+sk8=";
  };

  utilsSrc = fetchurl {
    url = "file://${distfiles}/crystal23/23-v1.0.1/utils23.tar.gz";
    hash = "sha256-bkUVLnoVYbiVlCV8Wx2xJlBa6qAoLkrAn8QeR4qdsyg=";
  };

  nativeBuildInputs = [
    autoPatchelfHook
    makeWrapper
  ];
  # The ifort binaries use only the F77 MPI bindings, so OpenMPI built with
  # gfortran serves them; LLVM's OpenMP provides libiomp5.
  buildInputs = [
    openmpi
    llvmPackages.openmp
    stdenv.cc.cc.lib
  ];

  dontUnpack = true;
  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    root="$out/lib/CRYSTAL23"
    arch="Linux-ifort"
    mkdir -p "$root/bin/$arch" "$out/bin"

    tar -xzf "$exeSrc" -C "$TMPDIR"
    cp -R "$TMPDIR"/crystal23_v1_0_1_Linux-ifort21.4_openmpi4.1.1_omp_exe/v1.0.1 "$root/bin/$arch/"

    tar -xzf "$utilsSrc" -C "$root"
    chmod -R u+w "$root"
    chmod +x "$root"/utils23/run* "$root/bin/$arch"/v1.0.1/*

    # The Linux archive ships OpenMP builds as crystalOMP and PcrystalOMP;
    # crystal and Pcrystal point at them so commands match macOS.
    for name in crystalOMP PcrystalOMP properties Pproperties crystal:crystalOMP Pcrystal:PcrystalOMP; do
      prog="$root/bin/$arch/v1.0.1/''${name#*:}"
      makeWrapper "$prog" "$out/bin/''${name%%:*}" \
        --set CRY23_ROOT "$root" \
        --set CRY23_ARCH "$arch" \
        --set VERSION "v1.0.1" \
        --prefix PATH : "$root/bin/$arch/v1.0.1:$root/utils23:${openmpi}/bin"
    done

    for script in "$root"/utils23/run*; do
      makeWrapper "$script" "$out/bin/$(basename "$script")" \
        --set CRY23_ROOT "$root" \
        --set CRY23_BIN "bin" \
        --set CRY23_ARCH "$arch" \
        --set VERSION "v1.0.1" \
        --set CRY23_EXEDIR "$root/bin/$arch" \
        --set CRY23_UTILS "$root/utils23" \
        --set-default CRY23_SCRDIR "/tmp" \
        --prefix PATH : "$root/bin/$arch/v1.0.1:$root/utils23:${openmpi}/bin:${tcsh}/bin"
    done

    runHook postInstall
  '';

  meta = {
    description = "CRYSTAL23 quantum chemistry package, manually supplied Linux x86-64 binaries";
    homepage = "https://www.crystal.unito.it/";
    license = lib.licenses.unfree;
    platforms = [ "x86_64-linux" ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
}
