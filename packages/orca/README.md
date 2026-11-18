# ORCA 6.1.1 macOS arm64

Exported as `orca`. The installer is not stored in Git; keep it at:

```text
/opt/distfiles/orca/6.1.1/orca_6_1_1_macosx_arm64_openmpi411.run
```

Verified hashes:

```text
sha1   c07dcaf0ca57c900b9a7e86756410922b2ce9833
sha256 0fb7b4d1994af5418286373e2c92da41e3a5d64b35438d8f5c6fb2e0242714ac
SRI    sha256-D7e00ZlK9UGChjc+LJLaQeOl1ks1Q42PXG+y4CQnFKw=
```

Build:

```sh
nix build .#orca
./result/bin/orca --version
```

Use the wrapped `orca` from `result/bin` or a project dev shell. Do not run
`$out/lib/orca/orca` directly; the wrapper provides `mpirun`, `ORCA_DIR`, and
the required macOS dynamic library paths for parallel jobs.
