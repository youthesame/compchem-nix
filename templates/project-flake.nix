{
  description = "Project dev shell using shared chemistry software";

  inputs = {
    software.url = "path:/Users/matsui-lab/Documents/software/nix";
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
          # Enable only the tools this project actually needs.
          # softwarePackages.orca     # Default ORCA alias, currently ORCA 6.1.1.
          # softwarePackages.orca611  # Fixed ORCA 6.1.1 for reproducible projects.
          # softwarePackages.orca610  # Fixed ORCA 6.1.0.
          # softwarePackages.crystal23
          # softwarePackages.gulp     # Default GULP alias, currently GULP 6.4.
          # softwarePackages.gulp64   # Fixed GULP 6.4.
          # softwarePackages.xtb      # Default ordinary xTB alias, currently xTB 6.7.1.
          # softwarePackages.xtb671   # Fixed ordinary xTB 6.7.1.
          # softwarePackages.cp2k     # Default CP2K alias, currently CP2K 2026.2.
          # softwarePackages.cp2k20262 # Fixed CP2K 2026.2.
        ];
      };
    };
}
