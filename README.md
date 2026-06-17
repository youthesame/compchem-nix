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
  gulp/
    default.nix
    README.md
  orca/
    default.nix
    README.md
```

Package-specific distfile paths, hashes, build commands, and smoke-test notes
live next to each package:

- [GULP](packages/gulp/README.md)
- [ORCA](packages/orca/README.md)

Reusable environments such as `gulp`, `orca`, and `chemistry` are exposed as
`devShells` from `flake.nix`.
