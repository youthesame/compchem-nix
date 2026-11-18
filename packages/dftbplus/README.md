# DFTB+ 25.1

## Packages

- `dftbplus`: DFTB+ 25.1.
- `dftb-3ob-3-1`: the 3ob-3-1 Slater-Koster set, in `share/slakos/3ob-3-1`
  (`packages/dftb-3ob-3-1`).

## Build

From the upstream release archive, which bundles tblite, dftd4, s-dftd3 and
their dependencies. gfortran and OpenBLAS; OpenMP on, MPI off, `WITH_TBLITE` on.
`WITH_SDFTD3` is on: `DftD3` needs the s-dftd3 library. D4 is built in.

OpenBLAS is pthreaded here: set both `OMP_NUM_THREADS` and
`OPENBLAS_NUM_THREADS` when running.

Apple Accelerate instead of OpenBLAS also passes all 443 tests, but was slower
on an M4 (3000-atom water SCC, 8 threads: 106 s vs 79–87 s), so it is not used.

## Tests

The full test suite is a flake check rather than part of the package build:

```sh
nix build .#checks.aarch64-darwin.dftbplus-tests --cores 4
```

25.1 passed all 443 tests here.

## Use

A project flake points DFTB+ at the parameters with
`DFTB_3OB = "${softwarePackages.dftb-3ob-3-1}/share/slakos/3ob-3-1";`.
