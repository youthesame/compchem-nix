{
  description = "Nix definitions for computational chemistry software";

  inputs = {
    # Every package except CP2K. The vendor ORCA and CRYSTAL23 binaries were
    # built against OpenMPI 4.1, but run on OpenMPI 5 (same libmpi.40 soname).
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    # CP2K 2026.2 needs the tblite 0.5 / dftd4 3.7 generation of the Grimme
    # libraries. Move this pin when moving to the next CP2K release.
    nixpkgs-cp2k.url = "github:NixOS/nixpkgs/567a49d1913ce81ac6e9582e3553dd90a955875f";
  };

  outputs = { self, nixpkgs, nixpkgs-cp2k, ... }:
    let
      systems = [ "aarch64-darwin" "x86_64-linux" ];
      lib = nixpkgs.lib;
      isDarwin = system: lib.hasSuffix "darwin" system;
      # Manually downloaded vendor files, kept outside Git and fetched by
      # fixed-output derivations, so no `nix store add-file` is needed.
      distfiles = "/opt/distfiles";

      forEachSystem = lib.genAttrs systems;
      config = {
        allowUnfree = true;
        allowUnsupportedSystem = true;
      };
      pkgsFor = system: import nixpkgs { inherit system config; };
      pkgsCp2kFor = system: import nixpkgs-cp2k {
        inherit system config;
        # libxsmm and the dbcsr and spglib tests do not build on darwin.
        overlays = lib.optionals (isDarwin system) [
          (final: prev: {
            dbcsr = prev.dbcsr.overrideAttrs (old: {
              buildInputs =
                (builtins.filter (pkg: (pkg.pname or "") != "libxsmm") (old.buildInputs or [ ]))
                ++ [ final.llvmPackages.openmp ];
              doCheck = false;
              cmakeFlags = builtins.map
                (flag:
                  if flag == "-DUSE_SMM=libxsmm" then
                    "-DUSE_SMM=blas"
                  else
                    flag)
                (old.cmakeFlags or [ ]);
            });
            spglib = prev.spglib.overrideAttrs (_: {
              doCheck = false;
            });
          })
        ];
      };
    in {
      packages = forEachSystem (system:
        let
          pkgs = pkgsFor system;
          pkgsCp2k = pkgsCp2kFor system;
          gnuStdenv = pkgs.stdenvAdapters.overrideCC pkgs.stdenv pkgs.gcc;
          # Vendor binaries differ per OS: packages/<name>/{darwin,linux}.nix.
          byOs = dir: dir + (if isDarwin system then "/darwin.nix" else "/linux.nix");
          # nixpkgs' openblas uses 64-bit integers on x86_64-linux; these
          # packages call BLAS and LAPACK with 32-bit integers.
          lp64 = p: p.openblas.override { blas64 = false; };
          cp2kBase = pkgsCp2k.callPackage ./packages/cp2k {
            stdenv = pkgsCp2k.stdenvAdapters.overrideCC pkgsCp2k.stdenv pkgsCp2k.gcc;
            openblas = lp64 pkgsCp2k;
          };
        in
        {
          orca = pkgs.callPackage (byOs ./packages/orca) { inherit distfiles; };
          crystal23 = pkgs.callPackage (byOs ./packages/crystal23) { inherit distfiles; };
          gulp = pkgs.callPackage ./packages/gulp { inherit distfiles; };
          cp2k = pkgsCp2k.callPackage ./packages/cp2k/2026.2.nix { cp2k = cp2kBase; };
          dftbplus = pkgs.callPackage ./packages/dftbplus {
            stdenv = gnuStdenv;
            openblas = lp64 pkgs;
          };
          dftb-3ob-3-1 = pkgs.callPackage ./packages/dftb-3ob-3-1 { };
          xtb = pkgs.callPackage ./packages/xtb (
            let
              # On darwin the meson builds of these Grimme libraries need libomp's omp.h.
              withOpenmp = pkg: if !(isDarwin system) then pkg else pkg.overrideAttrs (old: {
                buildInputs = (old.buildInputs or [ ]) ++ [ pkgs.llvmPackages.openmp ];
              });
              mctc-lib = pkgs.mctc-lib.overrideAttrs { doCheck = false; };
              multicharge = withOpenmp (pkgs.multicharge.override { inherit mctc-lib; });
            in
            {
              inherit mctc-lib multicharge;
              openblas = lp64 pkgs;
              dftd4 = withOpenmp (pkgs.dftd4.override { inherit mctc-lib multicharge; });
            });
          antechamber = pkgs.callPackage ./packages/amberclassic { };
        });

      checks = forEachSystem (system:
        let
          pkgs = pkgsFor system;
          cp2k = self.packages.${system}.cp2k;
        in
        {
          dftbplus-tests = self.packages.${system}.dftbplus.override { runTests = true; };
          # Regression check for rebuilds that change CP2K's toolchain or BLAS.
          cp2k-smoke = pkgs.runCommand "cp2k-smoke" {
            nativeBuildInputs = [ cp2k cp2k.mpi ];
          } ''
            bash ${./checks/cp2k/run.sh} ${./checks/cp2k} | tee $out
          '';
        });
    };
}
