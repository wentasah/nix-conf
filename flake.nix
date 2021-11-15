{
  inputs = {
    #nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs.url = "github:wentasah/nixpkgs/master";
    nixos-hardware.url = "github:NixOS/nixos-hardware";
    home-manager.url = "github:nix-community/home-manager";
  };

  outputs = { self, nixpkgs, nixos-hardware, home-manager }: {

    nixosConfigurations.steelpick = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules =
        [
          nixos-hardware.nixosModules.common-cpu-intel
          ./steelpick/configuration.nix
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.wsh = import ./steelpick/home.nix;
          }
        ];
    };
  };
}
