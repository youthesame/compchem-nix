# AmberClassic

AmberClassic is a smaller upstream subset of AmberTools. This package exposes
`antechamber`, `sqm`, `tleap`, `parmchk2`, and related classic AmberTools
utilities without packaging the full AmberTools distribution.

Source:

```text
https://github.com/Amber-MD/AmberClassic
```

## Build

```sh
nix build .#antechamber
./result/bin/antechamber -h
```

The package is exported as `antechamber`. The wrapper
sets `AMBERCLASSICHOME`, `AMBERHOME`, and the runtime library path.

## Notes

The package builds AmberClassic with:

```sh
./configure --clang --noboost
make install
```

This keeps the package smaller than full AmberTools while retaining the
`antechamber` workflow and its companion tools such as `sqm` and `parmchk2`.
