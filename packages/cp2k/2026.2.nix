{ cp2k, hdf5-fortran }:
(cp2k.override {
  version = "2026.2";
  # Parallel CP2K now calls the HDF5 MPI file-access API.
  hdf5-fortran = hdf5-fortran.override {
    mpiSupport = true;
    cppSupport = false;
    mpi = cp2k.mpi;
  };
  sourceHash = "sha256-ojG00n6KiaDW9vLgw/sIrhS8ceyh1mmlxgacw8KfMnA=";
}).overrideAttrs (old: {
  # 2026.2 discovers mctc-lib through tblite; retain the BLAS target aliases
  # before loading that dependency's CMake configuration.
  postPatch = builtins.replaceStrings
    [ "find_package(mctc-lib REQUIRED)" ]
    [ "find_package(tblite REQUIRED)" ]
    old.postPatch;
})
