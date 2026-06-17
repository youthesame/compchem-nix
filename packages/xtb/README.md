# xTB

Ordinary xTB is packaged separately from g-xTB.

## Version

- `xtb`: current default ordinary xTB, currently 6.7.1.
- `xtb671`: fixed ordinary xTB 6.7.1.

## Source

The package builds from the public upstream source release:

```text
https://github.com/grimme-lab/xtb/releases/download/v6.7.1/xtb-6.7.1-source.tar.xz
```

Upstream SHA256:

```text
79a2a2f50091b3b941e5139c1b38a53203d5d2e9ba496a7ad505d8c31ccd6013
```

Nix hash:

```text
sha256-eaKi9QCRs7lB5ROcGzilMgPV0um6SWp61QXYwxzNYBM=
```

## Build notes

- OpenMP is enabled for multicore runs.
- The upstream 6.7.1 source release reports `xtb version 6.7.0` in the runtime
  banner. The Nix package version is still fixed to the v6.7.1 release archive
  and hash above.
- `tblite` is disabled because the 6.7.1 source release expects a newer
  `tblite` API than nixpkgs 25.05 provides, and the upstream wrap file points to
  an unreproducible `head` revision.
- `cpcmx` is disabled because it is not available in this Nix package set.

## Quick checks

```sh
nix build .#xtb
nix develop .#xtb -c xtb --version
```
