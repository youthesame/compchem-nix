{
  description = "Reusable Nix software definitions";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    nixpkgs-openmpi4.url = "github:NixOS/nixpkgs/nixos-24.05";
  };

  outputs = { self, nixpkgs, nixpkgs-openmpi4, ... }:
    let
      systems = [
        "aarch64-darwin"
        "x86_64-linux"
      ];

      forEachSystem = nixpkgs.lib.genAttrs systems;
      pkgsFor = system: import nixpkgs {
        inherit system;
        config.allowUnfree = true;
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
    in {
      packages = forEachSystem (system:
        let
          pkgs = pkgsFor system;
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
          gulp60Openmpi4 = pkgsOpenmpi4.callPackage ./packages/gulp/6.0.nix {
            gfortran = pkgsOpenmpi4.gfortran12;
            openmpi = openmpi4ForGulp;
            scalapack = scalapackOpenmpi4ForGulp;
          };
        in
        {
          gulp = gulpOpenmpi4;
          gulp-openmpi4 = gulpOpenmpi4;
          gulp64 = gulpOpenmpi4;
          gulp60 = gulp60Openmpi4;
        } // pkgs.lib.optionalAttrs (system == "aarch64-darwin") {
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
          g-xtb = pkgs.callPackage ./packages/g-xtb {
            gccFortran = pkgsOpenmpi4.gfortran12;
          };
          default = self.packages.${system}.orca;
        });

      devShells = forEachSystem (system:
        let
          pkgs = pkgsFor system;
          pkgsOpenmpi4 = pkgsOpenmpi4For system;
          openmpi4ForGulp = (pkgsOpenmpi4.openmpi.override {
            gfortran = pkgsOpenmpi4.gfortran12;
          }).overrideAttrs (_: {
            doCheck = false;
          });
          packages = self.packages.${system};
        in
        {
          chemistry = pkgs.mkShell {
            packages = [
              packages.gulp
              openmpi4ForGulp
              (openmpi4ForGulp.dev or openmpi4ForGulp)
              pkgs.python3
              pkgs.openbabel
            ] ++ pkgs.lib.optionals (packages ? orca) [
              packages.orca
            ] ++ pkgs.lib.optionals (packages ? crystal23) [
              packages.crystal23
            ] ++ pkgs.lib.optionals (packages ? g-xtb) [
              packages.g-xtb
            ];
          };

          gulp = pkgs.mkShell {
            packages = [
              packages.gulp
              openmpi4ForGulp
              (openmpi4ForGulp.dev or openmpi4ForGulp)
            ];
          };
          gulp60 = pkgs.mkShell {
            packages = [
              packages.gulp60
              openmpi4ForGulp
              (openmpi4ForGulp.dev or openmpi4ForGulp)
            ];
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
        } // pkgs.lib.optionalAttrs (packages ? g-xtb) {
          g-xtb = pkgs.mkShell {
            packages = [
              packages.g-xtb
            ];
          };
        });
    };
}
