{
  description = "Public subset of Nix configurations.";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    ...
  } @ inputs: let
    inherit (self) outputs;
  in rec {
    packages = flake-utils.lib.eachDefaultSystem (
      system: import ./pkgs { pkgs = nixpkgs.legacyPackages.${system}; });
    overlays = import ./overlays {inherit inputs;};
    nixosModules = import ./modules/nixos;
  };
}
