# ORCA 6.1.1

Exported as `orca`, from `darwin.nix` or `linux.nix`. The vendor files are not
stored in Git; keep them at:

```text
/opt/distfiles/orca/6.1.1/orca_6_1_1_macosx_arm64_openmpi411.run
/opt/distfiles/orca/6.1.1/orca_6_1_1_linux_x86-64_shared_openmpi418_avx2.tar.xz
```

Verified hashes:

```text
orca_6_1_1_macosx_arm64_openmpi411.run
sha1   c07dcaf0ca57c900b9a7e86756410922b2ce9833
sha256 0fb7b4d1994af5418286373e2c92da41e3a5d64b35438d8f5c6fb2e0242714ac
SRI    sha256-D7e00ZlK9UGChjc+LJLaQeOl1ks1Q42PXG+y4CQnFKw=

orca_6_1_1_linux_x86-64_shared_openmpi418_avx2.tar.xz
sha1   9f85cd5c16d9c40d37ada53327da1e3c0e85409e
sha256 5eaf676f9711a38835d609264321a30266b487b65477547802dedee982bc82d5
SRI    sha256-Xq9nb5cRo4g11gkmQyGjAma0h7ZUd1R4At7e6YK8gtU=
```

Build:

```sh
nix build .#orca
./result/bin/orca --version
```

Use the wrapped `orca` from `result/bin` or a project dev shell. Do not run
`$out/lib/orca/orca` directly; the wrapper provides `mpirun`, `ORCA_DIR`, and
the macOS dynamic library paths for parallel jobs.
