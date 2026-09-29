{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  python3,
  gfortran,
  blas,
  lapack,
  openblas,
  dbcsr,
  fftw,
  libint,
  libvori,
  libxc_7,
  dftd4,
  simple-dftd3,
  tblite,
  mpi,
  scalapack,
  makeWrapper,
  spglib,
  which,
  pkg-config,
  zlib,
  hdf5-fortran,
  elpa,
  llvmPackages,
  newScope,
  mctc-lib,
  jonquil,
  multicharge,
  mstore,
  test-drive,
  toml-f,
  version ? "2026.1",
  sourceHash ? "sha256-1c4jM1Mdu7Lptjn8nQ/nYQpdXQa5mcm0NRsAU9Muw8w=",
  enableElpa ? false,
  enableLibint ? false,
}:

let
  grimmeCmake = lib.makeScope newScope (self: {
    mctc-lib = mctc-lib.override {
      buildType = "cmake";
      inherit (self) jonquil;
    };

    toml-f = toml-f.override {
      buildType = "cmake";
      inherit (self) test-drive;
    };

    dftd4 = (dftd4.override {
      buildType = "cmake";
      inherit (self) mstore mctc-lib multicharge;
    }).overrideAttrs (old: {
      buildInputs = (old.buildInputs or [ ]) ++ [ llvmPackages.openmp ];
    });

    jonquil = jonquil.override {
      buildType = "cmake";
      inherit (self) toml-f test-drive;
    };

    mstore = mstore.override {
      buildType = "cmake";
      inherit (self) mctc-lib;
    };

    multicharge = (multicharge.override {
      buildType = "cmake";
      inherit (self) mctc-lib mstore;
    }).overrideAttrs (old: {
      buildInputs = (old.buildInputs or [ ]) ++ [ llvmPackages.openmp ];
    });

    test-drive = test-drive.override { buildType = "cmake"; };

    simple-dftd3 = (simple-dftd3.override {
      buildType = "cmake";
      inherit (self) mctc-lib mstore toml-f;
    }).overrideAttrs (old: {
      buildInputs = (old.buildInputs or [ ]) ++ [ llvmPackages.openmp ];
    });

    tblite = (tblite.override {
      buildType = "cmake";
      inherit (self)
        mctc-lib
        mstore
        toml-f
        multicharge
        dftd4
        simple-dftd3
        ;
    }).overrideAttrs (old: {
      buildInputs = (old.buildInputs or [ ]) ++ [ llvmPackages.openmp ];
    });
  });

in
stdenv.mkDerivation (finalAttrs: {
  pname = "cp2k";
  inherit version;

  src = fetchFromGitHub {
    owner = "cp2k";
    repo = "cp2k";
    rev = "v${finalAttrs.version}";
    hash = sourceHash;
    fetchSubmodules = true;
  };

  nativeBuildInputs = [
    python3
    cmake
    which
    makeWrapper
    pkg-config
    gfortran
  ];

  buildInputs = [
    fftw
    libvori
    libxc_7
    mpi
    spglib
    scalapack
    openblas
    blas
    lapack
    dbcsr
    zlib
    hdf5-fortran
    llvmPackages.libcxx
    llvmPackages.openmp
    grimmeCmake.dftd4
    grimmeCmake.simple-dftd3
    grimmeCmake.tblite
    grimmeCmake.toml-f
  ]
  ++ lib.optional enableElpa elpa
  ++ lib.optional enableLibint libint;

  propagatedBuildInputs = [ (lib.getBin mpi) ];
  propagatedUserEnvPkgs = [ mpi ];

  postPatch = ''
    patchShebangs tools exts/dbcsr/tools/build_utils exts/dbcsr/.cp2k
    substituteInPlace CMakeLists.txt \
      --replace-fail "  find_package(mctc-lib REQUIRED)" "  find_package(BLAS REQUIRED)
  find_package(LAPACK REQUIRED)
  if(NOT TARGET BLAS::BLAS)
    add_library(BLAS::BLAS ALIAS cp2k::BLAS::blas)
  endif()
  if(NOT TARGET LAPACK::LAPACK)
    add_library(LAPACK::LAPACK ALIAS cp2k::LAPACK::lapack)
  endif()
  find_package(mctc-lib REQUIRED)"

    substituteInPlace cmake/modules/FindLibVORI.cmake \
      --replace-fail '"''${CP2K_LIBVORI_LINK_LIBRARIES}")' '"''${CP2K_LIBVORI_LINK_LIBRARIES};c++")
  set_target_properties(
    cp2k::VORI::vori PROPERTIES IMPORTED_LINK_INTERFACE_LANGUAGES "CXX")'

    substituteInPlace src/CMakeLists.txt \
      --replace-fail '  PUBLIC
    $<$<BOOL:''${CP2K_USE_MPI}>:__parallel>' '  PUBLIC
    __NO_STATM_ACCESS
    $<$<BOOL:''${CP2K_USE_MPI}>:__parallel>' \
      --replace-fail 'install(
  TARGETS ''${__CP2K_APPS} cp2k-bin grid_miniapp grid_unittest dbm_miniapp' 'set_target_properties(
  grid_miniapp grid_unittest dbm_miniapp
  PROPERTIES EXCLUDE_FROM_ALL TRUE)

install(
  TARGETS ''${__CP2K_APPS} cp2k-bin'
  '';

  cmakeFlags = [
    (lib.strings.cmakeBool "CP2K_USE_MPI" true)
    (lib.strings.cmakeBool "CP2K_USE_MPI_F08" true)
    (lib.strings.cmakeBool "CP2K_USE_DFTD4" true)
    (lib.strings.cmakeBool "CP2K_USE_TBLITE" true)
    (lib.strings.cmakeBool "CP2K_USE_FFTW3" true)
    (lib.strings.cmakeBool "CP2K_ENABLE_FFTW3_OPENMP_SUPPORT" true)
    (lib.strings.cmakeBool "CP2K_USE_HDF5" true)
    (lib.strings.cmakeBool "CP2K_USE_LIBINT2" enableLibint)
    (lib.strings.cmakeBool "CP2K_USE_LIBXC" true)
    (lib.strings.cmakeBool "CP2K_USE_VORI" true)
    (lib.strings.cmakeBool "CP2K_USE_SPGLIB" true)
    (lib.strings.cmakeBool "CP2K_USE_LIBXSMM" false)
    (lib.strings.cmakeBool "CP2K_USE_ELPA" enableElpa)
    (lib.strings.cmakeBool "CP2K_USE_SIRIUS" false)
    (lib.strings.cmakeBool "CP2K_USE_SPLA" false)
    (lib.strings.cmakeBool "CP2K_USE_LIBVDWXC" false)
    (lib.strings.cmakeBool "CP2K_USE_PLUMED" false)
    (lib.strings.cmakeBool "CP2K_USE_TREXIO" false)
    (lib.strings.cmakeBool "CP2K_USE_GREENX" false)
    (lib.strings.cmakeBool "CP2K_ENABLE_GRID_GPU" false)
    (lib.strings.cmakeBool "BUILD_SHARED_LIBS" (!stdenv.hostPlatform.isStatic))
    (lib.strings.cmakeFeature "CP2K_BLAS_VENDOR" "OpenBLAS")
    (lib.strings.cmakeFeature "CP2K_SCALAPACK_VENDOR" "GENERIC")
    (lib.strings.cmakeFeature "CP2K_USE_ACCEL" "NONE")
  ];

  passthru = {
    inherit mpi;
  };

  outputs = [
    "out"
    "dev"
  ];

  postInstall = ''
    mkdir -p $out/share/cp2k
    cp -r ../data/* $out/share/cp2k
    rm -f $out/lib/pkgconfig/libcp2k.pc

    for i in $out/bin/*; do
      wrapProgram $i \
        --set-default CP2K_DATA_DIR $out/share/cp2k \
        --set-default OMP_NUM_THREADS 1
    done
  '';

  doInstallCheck = false;

  meta = {
    description = "Quantum chemistry and solid state physics program";
    homepage = "https://www.cp2k.org";
    license = lib.licenses.gpl2Plus;
    platforms = [ "aarch64-darwin" ];
  };
})
