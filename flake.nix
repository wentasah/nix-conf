{
  inputs = {
    #nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs.url = "github:wentasah/nixpkgs/master";
    nixos-hardware.url = "github:NixOS/nixos-hardware";
    home-manager = { url = "github:nix-community/home-manager"; inputs.nixpkgs.follows  = "nixpkgs"; };
    sterm = { url = "github:wentasah/sterm"; inputs.nixpkgs.follows  = "nixpkgs"; };
    # For development:
    # sterm.url = "/home/wsh/src/sterm";
    notify-while-running = { url = "github:wentasah/notify-while-running"; flake = false; };
    nix-ld.url = "github:Mic92/nix-ld"; nix-ld.inputs.nixpkgs.follows = "nixpkgs";
    emacs-overlay.url = "github:nix-community/emacs-overlay";
  };

  outputs = { self, nixpkgs, nixos-hardware, home-manager, sterm, notify-while-running, nix-ld, emacs-overlay }: {

    nixosConfigurations.steelpick = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules =
        [
          nixos-hardware.nixosModules.common-cpu-intel
          ./steelpick/configuration.nix
          nix-ld.nixosModules.nix-ld
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            # home-manager.useUserPackages = true;
            home-manager.users.wsh = import ./steelpick/home.nix;
          }
          {
            # pin nixpkgs in the system-wide flake registry
            nix.registry.nixpkgs.flake = nixpkgs;

            nixpkgs.overlays = [
              sterm.overlay
              ( final: prev: { notify-while-running = import notify-while-running { pkgs = final; }; } )
              emacs-overlay.overlay
            ];
          }
        ];
    };
  };
}
