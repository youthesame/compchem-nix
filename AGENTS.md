# compchem-nix

- Target `aarch64-darwin` and `x86_64-linux`. Vendor binaries differ by
  platform, so their packages split into `darwin.nix` and `linux.nix`.
- One output name per package, no version aliases. Projects pin versions by
  locking this repository at a Git commit.
- Licensed vendor files go in `/opt/distfiles/<package>/<version>/` (dirs
  `755`, files `644`) and are fetched with
  `fetchurl { url = "file://${distfiles}/..."; hash = ...; }`. Never commit
  them.
- To add a package: add `packages/<name>/default.nix` and a `README.md` with the
  source, distfile path, hashes, and a smoke test, then export it in
  `flake.nix`.
- Before committing, run `nix flake check` and build the changed packages.
- When a change should not rebuild anything, compare `outPath` before and after
  with `nix eval`.
- Keep builds across GC with `nix build .#<pkg> --out-link gcroots/<pkg>`.
