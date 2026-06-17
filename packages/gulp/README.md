# GULP 6.4 MPI

The GULP source archive is kept outside Git at:

```text
~/Documents/software/distfiles/gulp/6.4/gulp-6.4.tgz
```

Verified hashes:

```text
sha1   f7846175a3f62aa92d71f042008d3b1297d68d95
sha256 ad6b5563ee5b9a90755e412cb11eeeba89eef8fb8c73c04b52c26cee68a61187
SRI    sha256-rWtVY+5bmpB1XkEssR7uuonu+PuMc8BLUsJs7mimEYc=
```

The default `gulp` package is pinned to the OpenMPI 4 toolchain from
`nixpkgs-openmpi4`, with gfortran pinned to 12:

```text
OpenMPI   4.1.6
gfortran  12.3.0
ScaLAPACK 2.2.1
OpenBLAS  0.3.27
```

Build:

```sh
nix store add-file ~/Documents/software/distfiles/gulp/6.4/gulp-6.4.tgz
nix build .#gulp
./result/bin/gulp
```

Interactive shell:

```sh
nix develop .#gulp
which gulp
which mpirun
which mpif90
```

Filename-based MPI runs are supported:

```sh
mpirun -np 4 gulp input_basename
```

Standard stdin redirection is also valid when the input file exists:

```sh
mpirun -np 6 gulp < input.gin > output.got
```

The wrapper sets `GULP_ROOT`, `GULP_LIB`, and `GULP_DOC`. On this macOS
machine, the OpenMPI 4/gfortran-12 variant has been validated with
`mpirun -np 6 gulp < input.gin > output.got` against `Examples/example1.gin`.
Ubuntu/Linux should still be verified separately for actual MPI runs.

## GULP 6.0 MPI

The GULP 6.0 source archive is kept outside Git at:

```text
~/Documents/software/distfiles/gulp/6.0/gulp-6.0.tgz
```

Verified hashes:

```text
sha1   1fece7bc22affb8b5d3857bb4ea119251cda0534
sha256 f73b0f68c8ba499e3f9f0d0de5e3b34307e0b8579387a4cb2b9cdfd1cf62e9d1
SRI    sha256-9zsPaMi6SZ4/nw0N5eOzQwfguFeTh6TLK5zf0c9i6dE=
```

Build:

```sh
nix store add-file ~/Documents/software/distfiles/gulp/6.0/gulp-6.0.tgz
nix build .#gulp60
```
