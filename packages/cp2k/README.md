# CP2K 2026.2

Exported as `cp2k`. `default.nix` is the base derivation, still at 2026.1; `2026.2.nix` overrides
its version, source hash, and HDF5. CP2K 2026.1 is no longer exported.

## Source

The package builds from the public upstream GitHub tag:

```text
https://github.com/cp2k/cp2k/tree/v2026.2
```

The Nix source hash is recorded in `packages/cp2k/2026.2.nix`.

## Build notes

This repository uses a custom CP2K derivation instead of the nixpkgs CP2K
package so the local flake can support Apple Silicon / `aarch64-darwin` with
custom dependency overrides in the `pkgsCp2k` overlay. The flake currently
overrides dependencies such as `dbcsr` (`USE_SMM=blas`).

CP2K builds from its own `nixpkgs-cp2k` input, pinned to a June 2026 nixpkgs.
CP2K 2026.2 needs tblite 0.5 and dftd4 3.7; later nixpkgs ships tblite 0.8 and
dftd4 4.3, which it does not compile against. Move the pin with the next CP2K
release, and run `nix flake check` (the `cp2k-smoke` check) after moving it.

Release builds would add `-mcpu=native`; `default.nix` replaces it with
`-mcpu=apple-m1` so the binary does not depend on the build machine.

The derivation builds CP2K with MPI enabled. GPU, SIRIUS, LIBXSMM, SPLA,
LIBVDWXC, PLUMED, TREXIO, GREENX, ELPA, and libint support are disabled in
`packages/cp2k/default.nix`.

## Quick checks

```sh
nix build .#cp2k
./result/bin/cp2k.psmp --version
```
