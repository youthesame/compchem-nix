{
  lib,
  stdenv,
  fetchurl,
  fetchzip,
  cmake,
  gfortran,
  python3,
  openblas,
  runTests ? false,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "dftbplus";
  version = "25.1";

  # The release archive carries every external component (tblite, dftd4,
  # s-dftd3, mctc-lib, ...) except the test parameters.
  src = fetchurl {
    url = "https://github.com/dftbplus/dftbplus/releases/download/${finalAttrs.version}/dftbplus-${finalAttrs.version}.tar.xz";
    hash = "sha256-CpuAQuloEFtT9JxW8FJOH57Ss8XFEbA8GuoLzEFtcnU=";
  };

  # The commit `utils/get_opt_externals slakos` pins for 25.1.
  testparams = fetchzip {
    url = "https://github.com/dftbplus/testparams/archive/0e1d95abc70339d017fd53d40c41c041057fd03f.tar.gz";
    hash = "sha256-sJ3K8McKQLCW8bg1LXlwbITAwNwHbn8J9yU1X5wKQsE=";
  };

  nativeBuildInputs = [
    cmake
    gfortran
    python3
  ];

  buildInputs = [ openblas ];

  postPatch = ''
    patchShebangs .
    # toml-f always adds its test suite, which fetches test-drive.
    substituteInPlace external/toml-f/origin/CMakeLists.txt \
      --replace-fail 'add_subdirectory("test")' ""
  ''
  + lib.optionalString runTests ''
    cp -R ${finalAttrs.testparams} external/slakos/origin
    chmod -R u+w external/slakos/origin
  '';

  cmakeFlags = [
    (lib.cmakeBool "WITH_OMP" true)
    (lib.cmakeBool "WITH_MPI" false)
    (lib.cmakeBool "WITH_TBLITE" true)
    # Build the bundled externals. `Find` must follow: 25.1 tests for
    # "(^|;)Submodule(^|;)", so "Submodule" alone skips the indirect
    # dependencies, and the sandbox leaves nothing else for it to find.
    (lib.cmakeFeature "HYBRID_CONFIG_METHODS" "Submodule;Find")
    # Otherwise CMake settles on Accelerate from the SDK.
    (lib.cmakeFeature "BLAS_LIBRARY" "openblas")
    (lib.cmakeFeature "BLAS_LIBRARY_DIR" "${lib.getLib openblas}/lib")
    (lib.cmakeFeature "LAPACK_LIBRARY" "NONE")
    (lib.cmakeFeature "TEST_OMP_THREADS" "1")
    # The bundled mstore writes "${prefix}/${CMAKE_INSTALL_LIBDIR}" into its
    # .pc file, which Nix's absolute install directories turn into "//".
    (lib.cmakeFeature "CMAKE_INSTALL_LIBDIR" "lib")
    (lib.cmakeFeature "CMAKE_INSTALL_INCLUDEDIR" "include")
  ];

  doCheck = runTests;
  checkPhase = ''
    runHook preCheck
    OMP_NUM_THREADS=1 OPENBLAS_NUM_THREADS=1 \
      ctest -j $NIX_BUILD_CORES --output-on-failure
    runHook postCheck
  '';

  meta = {
    description = "DFTB+ density functional tight binding package";
    homepage = "https://dftbplus.org";
    license = lib.licenses.lgpl3Plus;
    platforms = [ "aarch64-darwin" ];
    mainProgram = "dftb+";
  };
})
