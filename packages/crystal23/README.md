# CRYSTAL23 v1.0.1

Exported as `crystal23`, from `darwin.nix` or `linux.nix`. Each platform uses
its executable archive and the shared `utils23.tar.gz`:

```text
/opt/distfiles/crystal23/23-v1.0.1/crystal23_v1_0_1_MacOsX-gnu12.1_openmpi4.1.1_exe.tar.gz
/opt/distfiles/crystal23/23-v1.0.1/crystal23_v1_0_1_Linux-ifort21.4_openmpi4.1.1_omp_exe.tar.gz
/opt/distfiles/crystal23/23-v1.0.1/utils23.tar.gz
```

Verified hashes:

```text
crystal23_v1_0_1_MacOsX-gnu12.1_openmpi4.1.1_exe.tar.gz
sha1   f2432e434a836980b3add84e7a487bfb656a2e73
sha256 b01ce0036a32baf8695cd9af1b77c8d8c51030581bbf0df55ab9835ded6ef9c5
SRI    sha256-sBzgA2oyuvhpXNmvG3fI2MUQMFgbvw31WrmDXe1u+cU=

crystal23_v1_0_1_Linux-ifort21.4_openmpi4.1.1_omp_exe.tar.gz
sha1   8977c4c4d0ba43e0f0aab8cf10c31b9a1836e184
sha256 4e64acfbbb203435fbf028828a58f0268f190a7b4c49c419b47cb172e2feb24f
SRI    sha256-TmSs+7sgNDX78CiCiljwJo8ZCntMScQZtHyxcuL+sk8=

utils23.tar.gz
sha1   1d0cd8b6d18ba79c4c19fd0741285ad2ae49c48f
sha256 6e45152e7a1561b89594257c5b1db126505aeaa0282e4ac09fc41e478a9db328
SRI    sha256-bkUVLnoVYbiVlCV8Wx2xJlBa6qAoLkrAn8QeR4qdsyg=
```

Build:

```sh
nix build .#crystal23
```
