{
  description = "Nix definitions for computational chemistry software";

  inputs = {
    # Stable 25.05 baseline for most reusable chemistry packages.
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    # Unstable pin for newer CP2K toolchain/deps on aarch64-darwin.
    nixpkgs-cp2k.url = "github:NixOS/nixpkgs/nixos-unstable";
    # Keep OpenMPI 4.1.x + gfortran12 ABI for vendor ORCA/CRYSTAL23/GULP binaries.
    nixpkgs-openmpi4.url = "github:NixOS/nixpkgs/nixos-24.05";
  };

  outputs = { self, nixpkgs, nixpkgs-cp2k, nixpkgs-openmpi4, ... }:
    let
      # Only aarch64-darwin is verified; add Linux when it is set up.
      systems = [ "aarch64-darwin" ];
      # Manually downloaded vendor files, kept outside Git and fetched by
      # fixed-output derivations, so no `nix store add-file` is needed.
      distfiles = "/opt/distfiles";

      forEachSystem = nixpkgs.lib.genAttrs systems;
      pkgsFor = system: import nixpkgs {
        inherit system;
        config = {
          allowUnfree = true;
          allowUnsupportedSystem = true;
        };
        overlays = [
          (_final: prev: {
            mctc-lib = prev.mctc-lib.overrideAttrs (_: {
              doCheck = false;
            });
            multicharge = prev.multicharge.overrideAttrs (old: {
              buildInputs = (old.buildInputs or [ ]) ++ [ prev.llvmPackages.openmp ];
            });
            dftd4 = prev.dftd4.overrideAttrs (old: {
              buildInputs = (old.buildInputs or [ ]) ++ [ prev.llvmPackages.openmp ];
            });
            simple-dftd3 = prev.simple-dftd3.overrideAttrs (old: {
              buildInputs = (old.buildInputs or [ ]) ++ [ prev.llvmPackages.openmp ];
            });
          })
        ];
      };
      pkgsCp2kFor = system: import nixpkgs-cp2k {
        inherit system;
        config.allowUnsupportedSystem = true;
        overlays = [
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
      pkgsOpenmpi4For = system: import nixpkgs-openmpi4 {
        inherit system;
        config.allowUnfree = true;
        overlays = [
          (_final: prev: {
            gfortran = prev.gfortran12;
          })
        ];
      };
      perSystem = system:
        let
          pkgs = pkgsFor system;
          pkgsCp2k = pkgsCp2kFor system;
          pkgsOpenmpi4 = pkgsOpenmpi4For system;
          openmpi4ForGulp = (pkgsOpenmpi4.openmpi.override {
            gfortran = pkgsOpenmpi4.gfortran12;
          }).overrideAttrs (_: {
            doCheck = false;
          });
          scalapackOpenmpi4ForGulp = (pkgsOpenmpi4.scalapack.override {
            mpi = openmpi4ForGulp;
          }).overrideAttrs (old: {
            doCheck = false;
            NIX_CFLAGS_COMPILE = (old.NIX_CFLAGS_COMPILE or "") + " -Wno-implicit-function-declaration";
          });
          gulpOpenmpi4 = pkgsOpenmpi4.callPackage ./packages/gulp {
            inherit distfiles;
            gfortran = pkgsOpenmpi4.gfortran12;
            openmpi = openmpi4ForGulp;
            scalapack = scalapackOpenmpi4ForGulp;
          };
          xtbPackage = pkgs.callPackage ./packages/xtb { };
          amberclassicPackage = pkgs.callPackage ./packages/amberclassic { };
          dftbplusPackage = pkgs.callPackage ./packages/dftbplus {
            stdenv = pkgs.stdenvAdapters.overrideCC pkgs.stdenv pkgs.gcc;
          };
          dftb3ob31Package = pkgs.callPackage ./packages/dftb-3ob-3-1 { };
          cp2kGnuStdenv = pkgsCp2k.stdenvAdapters.overrideCC pkgsCp2k.stdenv pkgsCp2k.gcc;
          cp2kPackage = pkgsCp2k.callPackage ./packages/cp2k {
            stdenv = cp2kGnuStdenv;
          };
          cp2k20262Package = pkgsCp2k.callPackage ./packages/cp2k/2026.2.nix {
            cp2k = cp2kPackage;
          };
        in {
          inherit
            pkgs
            pkgsCp2k
            pkgsOpenmpi4
            openmpi4ForGulp
            gulpOpenmpi4
            xtbPackage
            amberclassicPackage
            dftbplusPackage
            dftb3ob31Package
            cp2kPackage
            cp2k20262Package;
        };
      systemsData = forEachSystem perSystem;
    in {
      packages = forEachSystem (system:
        let
          systemData = systemsData.${system};
          inherit (systemData) pkgs pkgsOpenmpi4 openmpi4ForGulp;
        in
        {
          gulp = systemData.gulpOpenmpi4;
          xtb = systemData.xtbPackage;
          antechamber = systemData.amberclassicPackage;
          dftb-3ob-3-1 = systemData.dftb3ob31Package;
          cp2k = systemData.cp2k20262Package;
          dftbplus = systemData.dftbplusPackage;
          orca = pkgs.callPackage ./packages/orca {
            inherit distfiles;
            openmpi = openmpi4ForGulp;
          };
          crystal23 = pkgs.callPackage ./packages/crystal23 {
            inherit distfiles;
            openmpi = openmpi4ForGulp;
            gccFortran = pkgsOpenmpi4.gfortran12;
          };
        });

      checks = forEachSystem (system:
        let
          pkgs = systemsData.${system}.pkgs;
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
