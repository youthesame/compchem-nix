{
  description = "Reusable Nix software definitions";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    nixpkgs-cp2k.url = "github:NixOS/nixpkgs/nixos-unstable";
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
            libxsmm = prev.libxsmm.overrideAttrs (old: {
              postPatch = (old.postPatch or "") + ''
                substituteInPlace Makefile.inc --replace-fail "-Wa,-q" ""
              '';
              meta = old.meta // {
                platforms = old.meta.platforms ++ [ "aarch64-darwin" ];
              };
            });
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
            elpa = (prev.elpa.override {
              stdenv = final.stdenvAdapters.overrideCC final.stdenv final.gcc;
            }).overrideAttrs (old: {
              buildInputs = (old.buildInputs or [ ]) ++ [ final.llvmPackages.openmp ];
              enableParallelBuilding = false;
              doCheck = false;
              postPatch = (old.postPatch or "") + ''
                substituteInPlace src/helpers/check_thread_affinity.c \
                  --replace-fail '#include <unistd.h>' '#include <unistd.h>
  #ifdef __APPLE__
  void get_thread_affinity(int *cpu_id) {
    *cpu_id = -1;
  }
  void get_process_affinity(int cpu_id) {
    (void)cpu_id;
  }
  #else' \
                  --replace-fail 'void get_process_id(int *process_id, int *pprocess_id) {' '#endif
  void get_process_id(int *process_id, int *pprocess_id) {'
              '';
              postInstall = (old.postInstall or "") + ''
                ln -s elpa.pc $dev/lib/pkgconfig/elpa_openmp.pc
              '';
              meta = old.meta // {
                platforms = old.meta.platforms ++ [ "aarch64-darwin" ];
              };
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
    in {
      packages = forEachSystem (system:
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
          gulp60Openmpi4 = pkgsOpenmpi4.callPackage ./packages/gulp/6.0.nix {
            gfortran = pkgsOpenmpi4.gfortran12;
            openmpi = openmpi4ForGulp;
            scalapack = scalapackOpenmpi4ForGulp;
          };
          xtbPackage = pkgs.callPackage ./packages/xtb { };
          cp2kGnuStdenv = pkgsCp2k.stdenvAdapters.overrideCC pkgsCp2k.stdenv pkgsCp2k.gcc;
          cp2kPackage = pkgsCp2k.callPackage ./packages/cp2k {
            stdenv = cp2kGnuStdenv;
          };
          cp2kLibintPackage = pkgsCp2k.callPackage ./packages/cp2k {
            stdenv = cp2kGnuStdenv;
            enableLibint = true;
          };
          cp2kElpaPackage = pkgsCp2k.callPackage ./packages/cp2k {
            stdenv = cp2kGnuStdenv;
            enableElpa = true;
          };
        in
        {
          cp2k20261 = cp2kPackage;
          cp2k20261-libint = cp2kLibintPackage;
          cp2k20261-elpa = cp2kElpaPackage;
          cp2k = cp2kPackage;
          gulp = gulpOpenmpi4;
          gulp-openmpi4 = gulpOpenmpi4;
          gulp64 = gulpOpenmpi4;
          gulp60 = gulp60Openmpi4;
          xtb = xtbPackage;
          xtb671 = xtbPackage;
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
          pkgsCp2k = pkgsCp2kFor system;
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
              packages.xtb
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
          xtb = pkgs.mkShell {
            packages = [
              packages.xtb
            ];
          };
          cp2k = pkgsCp2k.mkShell {
            packages = [
              packages.cp2k
              packages.cp2k.mpi
            ];
          };
          cp2k20261 = pkgsCp2k.mkShell {
            packages = [
              packages.cp2k20261
              packages.cp2k20261.mpi
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
