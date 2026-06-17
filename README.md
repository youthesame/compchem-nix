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
  g-xtb/
    default.nix
    README.md
  gulp/
    6.0.nix
    default.nix
    README.md
  orca/
    6.1.0.nix
    default.nix
    README.md
```

Package-specific distfile paths, hashes, build commands, and smoke-test notes
live next to each package:

- [GULP](packages/gulp/README.md)
- [ORCA](packages/orca/README.md)
- [CRYSTAL23](packages/crystal23/README.md)
- [g-xTB](packages/g-xtb/README.md)

Reusable environments such as `gulp`, `orca`, and `chemistry` are exposed as
`devShells` from `flake.nix`.

## Local distfiles now in use

```text
~/Documents/software/distfiles/gulp/6.4/gulp-6.4.tgz
~/Documents/software/distfiles/gulp/6.0/gulp-6.0.tgz
~/Documents/software/distfiles/orca/6.1.1/orca_6_1_1_macosx_arm64_openmpi411.run
~/Documents/software/distfiles/orca/6.1.0/orca_6_1_0_macosx_arm64_openmpi411.run
~/Documents/software/distfiles/crystal23/23-v1.0.1/crystal23_v1_0_1_MacOsX-gnu12.1_openmpi4.1.1_exe.tar.gz
~/Documents/software/distfiles/crystal23/23-v1.0.1/utils23.tar.gz
```

`g-xtb` 2.0.1 uses the public macOS arm64 GitHub release asset directly:

```text
https://github.com/grimme-lab/g-xtb/releases/download/v2.0.1/xtb-6.7.1-gxtb-140526-macos-arm64.tar.gz
```
