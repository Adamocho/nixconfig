{
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-23.11";
  };
  outputs = { self, nixpkgs, ... } @inputs: {
    nixosConfigurations.earth = nixpkgs.lib.nixosSystem rec {
      system = "x86_64-linux";
      specialArgs = { inherit inputs; };
      modules = [ ./configuration.nix ];
    };
  };
}
