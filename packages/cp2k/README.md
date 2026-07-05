# CP2K 2026.1

## Version

- `cp2k`: current default CP2K, currently 2026.1.
- `cp2k20261`: fixed CP2K 2026.1.
- `cp2k20261-libint`: CP2K 2026.1 with `enableLibint = true`.
- `cp2k20261-elpa`: CP2K 2026.1 with `enableElpa = true`.

This package is currently declared for `aarch64-darwin` only.

## Source

The package builds from the public upstream GitHub tag:

```text
https://github.com/cp2k/cp2k/tree/v2026.1
```

The Nix source hash is recorded in `packages/cp2k/default.nix`.

## Build notes

This repository uses a custom CP2K derivation instead of the nixpkgs CP2K
package so the local flake can support Apple Silicon / `aarch64-darwin` with
custom dependency overrides in the `pkgsCp2k` overlay. The flake currently
overrides dependencies such as `dbcsr` (`USE_SMM=blas`) and applies Darwin ELPA
patches for the optional ELPA variant.

The derivation builds CP2K with MPI enabled. GPU, SIRIUS, LIBXSMM, SPLA,
LIBVDWXC, PLUMED, TREXIO, and GREENX support are disabled in
`packages/cp2k/default.nix`.

## Quick checks

```sh
nix build .#cp2k20261
nix develop .#cp2k -c cp2k.psmp --version
```
