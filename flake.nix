{
  description = "Reusable Nix software definitions";

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
      systems = [
        "aarch64-darwin"
        "x86_64-linux"
      ];

      forEachSystem = nixpkgs.lib.genAttrs systems;
      pkgsFor = system: import nixpkgs {
        inherit system;
        config = {
          allowUnfree = true;
          allowUnsupportedSystem = system == "aarch64-darwin";
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
        config.allowUnsupportedSystem = system == "aarch64-darwin";
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
            gfortran = pkgsOpenmpi4.gfortran12;
            openmpi = openmpi4ForGulp;
            scalapack = scalapackOpenmpi4ForGulp;
          };
          xtbPackage = pkgs.callPackage ./packages/xtb { };
          amberclassicPackage = pkgs.callPackage ./packages/amberclassic { };
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
            cp2kPackage
            cp2k20262Package;
        };
      systemsData = forEachSystem perSystem;
    in {
      packages = forEachSystem (system:
        let
          systemData = systemsData.${system};
          inherit (systemData) pkgs pkgsOpenmpi4 openmpi4ForGulp gulpOpenmpi4 xtbPackage;
        in
        {
          gulp = gulpOpenmpi4;
          gulp-openmpi4 = gulpOpenmpi4;
          gulp64 = gulpOpenmpi4;
          xtb = xtbPackage;
          xtb671 = xtbPackage;
          antechamber = systemData.amberclassicPackage;
        } // pkgs.lib.optionalAttrs (system == "aarch64-darwin") {
          cp2k20262 = systemData.cp2k20262Package;
          cp2k = systemData.cp2k20262Package;
          orca = pkgs.callPackage ./packages/orca {
            openmpi = openmpi4ForGulp;
          };
          orca611 = pkgs.callPackage ./packages/orca {
            openmpi = openmpi4ForGulp;
          };
          orca610 = pkgs.callPackage ./packages/orca/6.1.0.nix {
            openmpi = openmpi4ForGulp;
          };
          crystal23 = pkgs.callPackage ./packages/crystal23 {
            openmpi = openmpi4ForGulp;
            gccFortran = pkgsOpenmpi4.gfortran12;
          };
          default = self.packages.${system}.orca;
        });

      devShells = forEachSystem (system:
        let
          systemData = systemsData.${system};
          inherit (systemData) pkgs pkgsCp2k openmpi4ForGulp;
          packages = self.packages.${system};
        in
        {
          chemistry = pkgs.mkShell {
            packages = [
              packages.gulp
              packages.xtb
              openmpi4ForGulp
              (openmpi4ForGulp.dev or openmpi4ForGulp)
              pkgs.python3
              pkgs.openbabel
            ] ++ pkgs.lib.optionals (packages ? orca) [
              packages.orca
            ] ++ pkgs.lib.optionals (packages ? crystal23) [
              packages.crystal23
            ];
          };

          gulp = pkgs.mkShell {
            packages = [
              packages.gulp
              openmpi4ForGulp
              (openmpi4ForGulp.dev or openmpi4ForGulp)
            ];
          };
          xtb = pkgs.mkShell {
            packages = [
              packages.xtb
            ];
          };
          antechamber = pkgs.mkShell {
            packages = [
              packages.antechamber
            ];
          };
        } // pkgs.lib.optionalAttrs (system == "aarch64-darwin") {
          cp2k = pkgsCp2k.mkShell {
            packages = [
              packages.cp2k
              packages.cp2k.mpi
            ];
          };
          cp2k20262 = pkgsCp2k.mkShell {
            packages = [ packages.cp2k20262 packages.cp2k20262.mpi ];
          };
        } // pkgs.lib.optionalAttrs (packages ? orca) {
          orca = pkgs.mkShell {
            packages = [
              packages.orca
              openmpi4ForGulp
            ];

            shellHook = ''
              export ORCA_DIR="${packages.orca}/lib/orca"
            '';
          };
          orca610 = pkgs.mkShell {
            packages = [
              packages.orca610
              openmpi4ForGulp
            ];

            shellHook = ''
              export ORCA_DIR="${packages.orca610}/lib/orca"
            '';
          };
        } // pkgs.lib.optionalAttrs (packages ? crystal23) {
          crystal23 = pkgs.mkShell {
            packages = [
              packages.crystal23
              openmpi4ForGulp
            ];
          };
        });
    };
}
