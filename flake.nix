{
  inputs = {
    #nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs.url = "github:wentasah/nixpkgs/master";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-21.11";
    nixos-hardware.url = "github:NixOS/nixos-hardware";
    home-manager = { url = "github:nix-community/home-manager"; inputs.nixpkgs.follows = "nixpkgs"; };
    sterm = { url = "github:wentasah/sterm"; inputs.nixpkgs.follows = "nixpkgs"; };
    # For development:
    # sterm.url = "/home/wsh/src/sterm";
    notify-while-running = { url = "github:wentasah/notify-while-running"; flake = false; };
    emacs-overlay.url = "github:nix-community/emacs-overlay";
    novaboot = { url = "github:wentasah/novaboot/nfs"; inputs.nixpkgs.follows = "nixpkgs"; };
    nix-autobahn = { url = "github:Lassulus/nix-autobahn"; inputs.nixpkgs.follows = "nixpkgs"; };
  };

  outputs =
    { self
    , nixpkgs
    , nixpkgs-stable
    , nixos-hardware
    , home-manager
    , sterm
    , notify-while-running
    , emacs-overlay
    , novaboot
    , nix-autobahn
    }: {

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
            {
              # pin nixpkgs in the system-wide flake registry
              nix.registry.nixpkgs.flake = nixpkgs;

              nixpkgs.overlays = [
                sterm.overlay
                (final: prev: {
                  notify-while-running = import notify-while-running { pkgs = final; };
                  inherit (nix-autobahn.packages.x86_64-linux) nix-autobahn;
                })
                emacs-overlay.overlay
                novaboot.overlays.x86_64-linux
              ];
            }
          ];
      };
    };
}
