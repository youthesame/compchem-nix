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
