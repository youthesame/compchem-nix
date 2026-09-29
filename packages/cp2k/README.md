# CP2K 2026.2

## Version

- `cp2k`: current default CP2K, currently 2026.2.
- `cp2k20262`: fixed CP2K 2026.2.

`default.nix` is the base derivation, still at 2026.1; `2026.2.nix` overrides
its version, source hash, and HDF5. CP2K 2026.1 is no longer exported.

This package is currently declared for `aarch64-darwin` only.

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

The derivation builds CP2K with MPI enabled. GPU, SIRIUS, LIBXSMM, SPLA,
LIBVDWXC, PLUMED, TREXIO, GREENX, ELPA, and libint support are disabled in
`packages/cp2k/default.nix`.

## Quick checks

```sh
nix build .#cp2k20262
nix develop .#cp2k -c cp2k.psmp --version
```
