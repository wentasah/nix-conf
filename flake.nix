{
  inputs = {
    #nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs.url = "github:wentasah/nixpkgs/master";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-22.11";

    devenv = { url = github:cachix/devenv/v0.3; inputs.nixpkgs.follows = "nixpkgs"; };
    emacs-overlay = { url = "github:nix-community/emacs-overlay"; inputs.nixpkgs.follows = "nixpkgs"; };
    envfs = { url = "github:Mic92/envfs"; inputs.nixpkgs.follows = "nixpkgs"; };
    home-manager = { url = "github:nix-community/home-manager"; inputs.nixpkgs.follows = "nixpkgs"; };
    home-manager-stable = { url = "github:nix-community/home-manager/release-22.11"; inputs.nixpkgs.follows = "nixpkgs-stable"; };
    nix-autobahn = { url = "github:Lassulus/nix-autobahn"; inputs.nixpkgs.follows = "nixpkgs"; };
    nixos-hardware = { url = "github:NixOS/nixos-hardware"; };
    notify-while-running = { url = "github:wentasah/notify-while-running"; flake = false; };
    novaboot = { url = "github:wentasah/novaboot/nfs"; inputs.nixpkgs.follows = "nixpkgs"; };
    shdw = { url = "github:wentasah/shdw"; inputs.nixpkgs.follows = "nixpkgs"; };
    sterm = { url = "github:wentasah/sterm"; inputs.nixpkgs.follows = "nixpkgs"; };
  };

  outputs =
    { self
    , nixpkgs
    , nixpkgs-stable
    , nixos-hardware
    , home-manager
    , home-manager-stable
    , sterm
    , notify-while-running
    , emacs-overlay
    , novaboot
    , nix-autobahn
    , shdw
    , envfs
    , devenv
    }:
    let
      common-overlays = [
        emacs-overlay.overlay
        novaboot.overlays.x86_64-linux
        shdw.overlays.default
        sterm.overlay
        (final: prev: {
          notify-while-running = import notify-while-running { pkgs = final; };
          inherit (nix-autobahn.packages.x86_64-linux) nix-autobahn;
          inherit (devenv.packages.x86_64-linux) devenv;
          # https://github.com/nix-community/home-manager/issues/3361#issuecomment-1324310517
          #nix-zsh-completions = prev.nix-zsh-completions.overrideAttrs (old: {  postPatch = "rm _nix"; });
        })
      ];
    in
    {

      nixosConfigurations.steelpick = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./machines/steelpick/configuration.nix
          nixos-hardware.nixosModules.common-cpu-intel
          envfs.nixosModules.envfs
          home-manager.nixosModules.home-manager
          {
            # pin nixpkgs in the system-wide flake registry
            nix.registry.nixpkgs.flake = nixpkgs;
            nixpkgs.overlays = common-overlays;
          }
        ];
      };

      nixosConfigurations.resox = nixpkgs-stable.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./machines/resox/configuration.nix
          nixos-hardware.nixosModules.common-cpu-amd-pstate
          nixos-hardware.nixosModules.common-gpu-amd
          home-manager-stable.nixosModules.home-manager
          {
            # pin nixpkgs in the system-wide flake registry
            nix.registry.nixpkgs.flake = nixpkgs-stable;
            nixpkgs.overlays = common-overlays ++ [
              (final: prev: {
                # Packages from unstable
                d2 = nixpkgs.outputs.legacyPackages.x86_64-linux.d2;
                julia-stable-bin = nixpkgs.outputs.legacyPackages.x86_64-linux.julia-stable-bin;
              })
            ];
          }
        ];
      };

      nixosConfigurations.turbot = nixpkgs-stable.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./machines/turbot/configuration.nix
          ./machines/turbot/hardware-configuration.nix
        ];
      };

      homeConfigurations.ritchie = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages."x86_64-linux";
        modules = [
          ./modules/home-base.nix
          ./modules/fonts.nix
          {
            # https://nix-community.github.io/home-manager/index.html#sec-usage-configuration
            home.username = "sojka";
            home.homeDirectory = "/home/sojka";
            home.stateVersion = "22.05";
            programs.home-manager.enable = true;
            nixpkgs.overlays = common-overlays;
          }
        ];
      };

      checks.x86_64-linux = {
        resox = self.nixosConfigurations.resox.config.system.build.toplevel;
        ritchie = self.homeConfigurations.ritchie.activationPackage;
        steelpick = self.nixosConfigurations.steelpick.config.system.build.toplevel;
      };
    };
}
