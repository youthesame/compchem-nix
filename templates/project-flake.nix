{
  description = "Project dev shell using shared chemistry software";

  inputs = {
    # Commit catalog changes first: the lock records a Git revision.
    software.url = "git+file:///Users/matsui-lab/Documents/software/nix";
    nixpkgs.follows = "software/nixpkgs";
  };

  outputs = { nixpkgs, software, ... }:
    let
      system = "aarch64-darwin";
      pkgs = import nixpkgs { inherit system; };
      softwarePackages = software.packages.${system};
    in {
      devShells.${system}.default = pkgs.mkShellNoCC {
        packages = [
          # Enable only the tools this project needs.
          # softwarePackages.orca
          # softwarePackages.crystal23
          # softwarePackages.gulp
          # softwarePackages.cp2k
          # softwarePackages.cp2k.mpi
          # softwarePackages.dftbplus
          # softwarePackages.xtb
          # softwarePackages.antechamber
        ];
        # With dftbplus:
        # DFTB_3OB = "${softwarePackages.dftb-3ob-3-1}/share/slakos/3ob-3-1";
      };
    };
}
