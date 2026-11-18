# CRYSTAL23 v1.0.1 macOS arm64

CRYSTAL23 uses two manually supplied files:

```text
/opt/distfiles/crystal23/23-v1.0.1/crystal23_v1_0_1_MacOsX-gnu12.1_openmpi4.1.1_exe.tar.gz
/opt/distfiles/crystal23/23-v1.0.1/utils23.tar.gz
```

Verified hashes:

```text
crystal23_v1_0_1_MacOsX-gnu12.1_openmpi4.1.1_exe.tar.gz
sha1   f2432e434a836980b3add84e7a487bfb656a2e73
sha256 b01ce0036a32baf8695cd9af1b77c8d8c51030581bbf0df55ab9835ded6ef9c5
SRI    sha256-sBzgA2oyuvhpXNmvG3fI2MUQMFgbvw31WrmDXe1u+cU=

utils23.tar.gz
sha1   1d0cd8b6d18ba79c4c19fd0741285ad2ae49c48f
sha256 6e45152e7a1561b89594257c5b1db126505aeaa0282e4ac09fc41e478a9db328
SRI    sha256-bkUVLnoVYbiVlCV8Wx2xJlBa6qAoLkrAn8QeR4qdsyg=
```

Build:

```sh
nix build .#crystal23
```
