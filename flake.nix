{
 description = "my nixos config";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-24.05";
  };
  outputs = { self, nixpkgs, ... } @inputs: {
    nixosConfigurations = {

      earth = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [ 
          ./hosts/earth/configuration.nix
        ];
      };

      moon = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [ 
          ./hosts/moon/configuration.nix
        ];
      };
    };

  };
}
