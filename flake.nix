{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
  inputs.disko.url = "github:nix-community/disko";
  inputs.disko.inputs.nixpkgs.follows = "nixpkgs";
  inputs.nix-freifunk = {
    url = "github:nix-freifunk/nix-freifunk";
    flake = false;
  };

  outputs =
    {
      nixpkgs,
      disko,
      ...
    }@inputs:
    {
      nixosConfigurations.hetzner-cloud = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          disko.nixosModules.disko
          ./configuration.nix
          "${inputs.nix-freifunk}/fastd.nix"
        ];
      };
    };
}
