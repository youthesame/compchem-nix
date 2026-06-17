# ORCA 6.1.1 macOS arm64

The ORCA installer is not stored in Git. Keep the manually downloaded file at:

```text
~/Documents/software/distfiles/orca/6.1.1/orca_6_1_1_macosx_arm64_openmpi411.run
```

Verified hashes:

```text
sha1   c07dcaf0ca57c900b9a7e86756410922b2ce9833
sha256 0fb7b4d1994af5418286373e2c92da41e3a5d64b35438d8f5c6fb2e0242714ac
SRI    sha256-D7e00ZlK9UGChjc+LJLaQeOl1ks1Q42PXG+y4CQnFKw=
```

Build:

```sh
nix store add-file ~/Documents/software/distfiles/orca/6.1.1/orca_6_1_1_macosx_arm64_openmpi411.run
nix build .#orca
./result/bin/orca --version
```

Interactive shell:

```sh
nix develop .#orca
orca --version
```

Use the wrapped `orca` from `result/bin` or `nix develop`. Do not run
`$out/lib/orca/orca` directly; the wrapper provides `mpirun`, `ORCA_DIR`, and
the required macOS dynamic library paths for parallel jobs.

## ORCA 6.1.0 macOS arm64

The ORCA 6.1.0 installer is not stored in Git. Keep the manually downloaded file at:

```text
~/Documents/software/distfiles/orca/6.1.0/orca_6_1_0_macosx_arm64_openmpi411.run
```

Verified hashes:

```text
sha1   fde3a0a5682eaaca5e9f077cfeba2c75a41e19d0
sha256 1e16bdeee364a514bb1b304ca7b41d67df1c8471021d5e6c1ec0737d37c749ad
SRI    sha256-Hha97uNkpRS7GzBMp7QdZ98chHECHV5sHsBzfTfHSa0=
```

Build:

```sh
nix store add-file ~/Documents/software/distfiles/orca/6.1.0/orca_6_1_0_macosx_arm64_openmpi411.run
nix build .#orca610
```
