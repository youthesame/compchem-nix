# software/nix

Reusable Nix definitions for manually managed scientific software.

This repository contains package definitions only. Large manually downloaded
vendor files are kept outside Git:

```text
~/Documents/software/distfiles/
```

## Quick checks

```sh
nix flake check --no-build
nix build .#gulp
nix develop .#gulp -c which gulp
```

## Packages

```text
packages/
  crystal23/
    default.nix
    README.md
  cp2k/
    2026.2.nix
    default.nix
    README.md
  gulp/
    default.nix
    README.md
  orca/
    6.1.0.nix
    default.nix
    README.md
  xtb/
    default.nix
  amberclassic/
    default.nix
    README.md
```

Package-specific distfile paths, hashes, build commands, and smoke-test notes
live next to each package:

- [GULP](packages/gulp/README.md)
- [ORCA](packages/orca/README.md)
- [CRYSTAL23](packages/crystal23/README.md)
- [CP2K](packages/cp2k/README.md) (`aarch64-darwin` only)
- [xTB](packages/xtb/README.md)
- [antechamber (AmberClassic)](packages/amberclassic/README.md)

Reusable environments such as `gulp`, `orca`, `cp2k`, `antechamber`, and
`chemistry` are exposed as `devShells` from `flake.nix`.

## Project flake template

Use [templates/project-flake.nix](templates/project-flake.nix) when a project
should consume this shared software repo. Project flakes should normally list
only external scientific binaries. Keep Python and `uv` managed outside Nix.

Use aliases such as `orca` or `gulp` for convenient current defaults. Use
versioned aliases such as `orca611`, `orca610`, `gulp64`, `xtb671`, or `cp2k20262`
when a project needs stricter reproducibility.


## Local distfiles now in use

```text
~/Documents/software/distfiles/gulp/6.4/gulp-6.4.tgz
~/Documents/software/distfiles/orca/6.1.1/orca_6_1_1_macosx_arm64_openmpi411.run
~/Documents/software/distfiles/orca/6.1.0/orca_6_1_0_macosx_arm64_openmpi411.run
~/Documents/software/distfiles/crystal23/23-v1.0.1/crystal23_v1_0_1_MacOsX-gnu12.1_openmpi4.1.1_exe.tar.gz
~/Documents/software/distfiles/crystal23/23-v1.0.1/utils23.tar.gz
```

Ordinary `xTB` 6.7.1 uses the public upstream source release directly:

```text
https://github.com/grimme-lab/xtb/releases/download/v6.7.1/xtb-6.7.1-source.tar.xz
```

AmberClassic 2.0 uses the public upstream GitHub source release directly:

```text
https://github.com/Amber-MD/AmberClassic/releases/tag/v2.0
```
