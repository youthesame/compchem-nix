# compchem-nix

Nix definitions for the computational chemistry software I use on
`aarch64-darwin` and `x86_64-linux`. Licensed vendor files are not included.

## Packages

| Output | Software | Source |
|---|---|---|
| `orca` | [ORCA 6.1.1](packages/orca/README.md) | vendor binary, distfile |
| `crystal23` | [CRYSTAL23 v1.0.1](packages/crystal23/README.md) | vendor binary, distfile |
| `gulp` | [GULP 6.4](packages/gulp/README.md) | licensed source, distfile |
| `cp2k` | [CP2K 2026.2](packages/cp2k/README.md) | upstream source |
| `dftbplus`, `dftb-3ob-3-1` | [DFTB+ 25.1 and 3ob-3-1](packages/dftbplus/README.md) | upstream source |
| `xtb` | [xTB 6.7.1](packages/xtb/README.md) | upstream source |
| `antechamber` | [AmberClassic 2.0](packages/amberclassic/README.md) | upstream source |

Each output name is the only name for its package. A project pins the version
by locking this repository at a Git commit.

## Distfiles

Manually downloaded vendor files live outside Git in `/opt/distfiles`, and the
packages fetch them with `file://` URLs:

```text
/opt/distfiles/<package>/<version>/<file>
```

The Nix build user must be able to read them, so keep directories `755` and
files `644`. Do not move them under the home directory: the build user cannot
read it, and macOS protects `~/Documents`.

On Linux the build sandbox hides `/opt`, so add
`extra-sandbox-paths = /opt/distfiles` to `/etc/nix/nix.conf` and restart
`nix-daemon`.

## Checks

```sh
nix flake check
nix build .#<package> --out-link gcroots/<package>
```

`gcroots/` (Git-ignored) keeps the catalog's own builds across
`nix-store --gc`.

`nix flake check` runs the DFTB+ test suite and `cp2k-smoke`, which runs the
inputs in `checks/cp2k/` on 2 MPI ranks and compares the energy, largest
force, and pressure with `checks/cp2k/reference.txt`. Run it before and after
any change that rebuilds CP2K. Update the reference only when a change is
expected to move the numbers.

## Using it in a project

Copy [templates/project-flake.nix](templates/project-flake.nix) into the
project and enable the packages it needs. The template locks this repository
with `git+file:`, so commit catalog changes before running `nix flake update
software` in a project.

With direnv and nix-direnv installed, an untracked `.envrc` containing
`use flake` loads the shell on `cd` and keeps it from garbage collection.
