{
  inputs = {
    #nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs.url = "github:wentasah/nixpkgs/master";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-24.05";

    carla-stable = { url = "github:CTU-IIG/carla-simulator.nix/24.05"; inputs.nixpkgs.follows = "nixpkgs-stable"; };
    emacs-overlay = { url = "github:nix-community/emacs-overlay"; inputs.nixpkgs.follows = "nixpkgs"; inputs.nixpkgs-stable.follows = "nixpkgs-stable"; };
    findrepo.url = "github:wentasah/findrepo";
    flake-compat.url = "https://flakehub.com/f/edolstra/flake-compat/1.tar.gz";
    home-manager = { url = "github:nix-community/home-manager"; inputs.nixpkgs.follows = "nixpkgs"; };
    home-manager-stable = { url = "github:nix-community/home-manager/release-24.05"; inputs.nixpkgs.follows = "nixpkgs-stable"; };
    nix-autobahn = { url = "github:Lassulus/nix-autobahn"; inputs.nixpkgs.follows = "nixpkgs"; };
    nix-index-database = { url = "github:Mic92/nix-index-database"; inputs.nixpkgs.follows = "nixpkgs"; };
    nix-xilinx = { url = "gitlab:doronbehar/nix-xilinx"; inputs.nixpkgs.follows = "nixpkgs"; };
    nixos-hardware = { url = "github:NixOS/nixos-hardware"; };
    notify-while-running = { url = "github:wentasah/notify-while-running"; flake = false; };
    novaboot = { url = "github:wentasah/novaboot/nfs"; inputs.nixpkgs.follows = "nixpkgs"; };
    shdw = { url = "github:wentasah/shdw"; inputs.nixpkgs.follows = "nixpkgs"; };
    sops-nix = { url = "github:Mic92/sops-nix"; inputs.nixpkgs.follows = "nixpkgs"; inputs.nixpkgs-stable.follows = "nixpkgs-stable"; };
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
    , ...
    } @ inputs:
    let
      inherit (nixpkgs) lib;

      # Flakes require ‘packages’ attribute to contain per-platform attrsets.
      # Here we explicitly define all the platforms that will be exposed.
      platforms = [
        "x86_64-linux"
        #"aarch64-linux"
      ];

      forAllPlatforms = f: lib.genAttrs platforms f;

      common-overlays = platform: [
        emacs-overlay.overlay
        novaboot.overlays.${platform}
        shdw.overlays.default
        sterm.overlay
        inputs.findrepo.overlays.default
        (final: prev: {
          notify-while-running = import notify-while-running { pkgs = final; };
          inherit (nix-autobahn.packages.${platform}) nix-autobahn;
          fastdds = final.callPackage ./pkgs/fastdds { };
          flamenco = final.callPackage ./pkgs/flamenco {};
          foxglove-studio = final.callPackage ./pkgs/foxglove-studio { };
          # https://github.com/nix-community/home-manager/issues/3361#issuecomment-1324310517
          #nix-zsh-completions = prev.nix-zsh-completions.overrideAttrs (old: {  postPatch = "rm _nix"; });
          veridian = final.callPackage ./pkgs/veridian { };
          # Add python packages for using in Blender Addons (prepared for 23.11)
          pythonPackagesExtensions = prev.pythonPackagesExtensions ++ [
            (python-final: python-prev: {
              pyclothoids = python-final.callPackage ./pkgs/pyclothoids.nix { };
              scenariogeneration = python-final.callPackage ./pkgs/scenariogeneration.nix { };
            })
          ];
        })
      ];
      # Create combined package set from nixpkgs and our overlays.
      mkPkgs = platform: import nixpkgs {
        system = platform;
        overlays = common-overlays platform;
      };
    in
    {
      # Packages to test nix-update
      legacyPackages =  forAllPlatforms mkPkgs;

      nixosConfigurations = {
        steelpick = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            ./machines/steelpick/configuration.nix
            nixos-hardware.nixosModules.common-cpu-intel
            home-manager.nixosModules.home-manager
            inputs.sops-nix.nixosModules.sops
            inputs.nix-index-database.nixosModules.nix-index
            {
              # pin nixpkgs in the system-wide flake registry
              nix.registry.nixpkgs.flake = nixpkgs;
              nixpkgs.overlays = (common-overlays "x86_64-linux") ++ [
                inputs.nix-xilinx.overlay
                (final: prev: {
                  # Packages from stable
                  inherit (nixpkgs-stable.outputs.legacyPackages.x86_64-linux)
                    ;
                })
              ];
            }
          ];
        };

        resox = nixpkgs-stable.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            ./machines/resox/configuration.nix
            nixos-hardware.nixosModules.common-cpu-amd-pstate
            nixos-hardware.nixosModules.common-gpu-amd
            home-manager-stable.nixosModules.home-manager
            inputs.sops-nix.nixosModules.sops
            inputs.nix-index-database.nixosModules.nix-index
            {
              # pin nixpkgs in the system-wide flake registry
              nix.registry.nixpkgs.flake = nixpkgs-stable;
              nixpkgs.overlays = (common-overlays "x86_64-linux") ++ [
                inputs.carla-stable.overlays."0.9.15"
                (final: prev: {
                  # Packages from unstable
                  inherit (nixpkgs.outputs.legacyPackages.x86_64-linux) sequoia-sq yazi;
                })
              ];
            }
          ];
        };
        lucka-ntb = nixpkgs-stable.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [ ./machines/lucka-ntb/configuration.nix ];
        };
        turbot = nixpkgs-stable.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            ./machines/turbot/configuration.nix
            ./machines/turbot/hardware-configuration.nix
          ];
        };
      };

      homeConfigurations = {
        ritchie = let
          pkgs = nixpkgs.legacyPackages."x86_64-linux";
        in home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = [
            ./modules/home-base.nix
            ./modules/fonts.nix
            {
              # https://nix-community.github.io/home-manager/index.html#sec-usage-configuration
              home.username = "sojka";
              home.homeDirectory = "/home/sojka";
              home.stateVersion = "22.05";
              programs.home-manager.enable = true;
              nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
                "aspell-dict-en-science"
              ];
              nixpkgs.overlays = common-overlays "x86_64-linux";

              programs.zsh.envExtra = ''
                if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then
                  . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
                fi
              '';
              home.packages = with pkgs; [
                # Override btop to show GPU statistics
                (hiPrio (writeShellScriptBin "btop" ''LD_PRELOAD=/usr/lib/x86_64-linux-gnu/libnvidia-ml.so.1 ${btop}/bin/btop "$@"''))
              ];
            }
          ];
        };
      };

      checks.x86_64-linux = {
        resox = self.nixosConfigurations.resox.config.system.build.toplevel;
        ritchie = self.homeConfigurations.ritchie.activationPackage;
        steelpick = self.nixosConfigurations.steelpick.config.system.build.toplevel;
      };
    };
}
