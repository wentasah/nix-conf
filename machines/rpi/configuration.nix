{ config, pkgs, inputs, lib, modulesPath, ... }:

{
  imports = [ "${modulesPath}/profiles/perlless.nix" ];

  # Override perlless - mc still depends on perl
  system.forbiddenDependenciesRegexes = lib.mkForce [ ];

  boot = {
    initrd.availableKernelModules = [ "xhci_pci" "usbhid" "usb_storage" ];
  };

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-label/NIXOS_SD";
      fsType = "ext4";
      options = [ "noatime" ];
    };
  };

  nix = {
    settings.experimental-features = "nix-command flakes";
    settings.trusted-users = [ "root" "@wheel" ];

    # explicitly set nix-path, NIX_PATH to nixpkgs from system registry
    settings.nix-path = [ "nixpkgs=flake:nixpkgs" ];
    settings.auto-optimise-store = true;

    nixPath = config.nix.settings.nix-path;

    gc = {
      automatic = true;
      options = "--delete-older-than 4d";
      persistent = true;
      dates = [ "daily" ];
    };
  };

  xdg = {
    autostart.enable = false;
    icons.enable = false;
    mime.enable = false;
    sounds.enable = false;
  };

  documentation.nixos.enable = false;

  networking.hostName = "homeassistant";

  time.timeZone = "Europe/Prague";

  i18n.extraLocales = [
    "cs_CZ.UTF-8/UTF-8"
  ];

  environment.systemPackages = with pkgs; [
    btop
    htop
    kitty.terminfo
    mc
    vim
  ];

  services.userborn.enable = true;

  systemd.services.librespot = {
    enable = true;
    description = "librespot Spotify client";
    wantedBy = [ "multi-user.target" ];
    wants = [ "network.target" "sound.target" ];
    after = [ "network.target" "sound.target" ];
    serviceConfig = {
      Type = "simple";
      SupplementaryGroups = [ "audio" ];
      ExecStart = "${pkgs.librespot}/bin/librespot --name 'Věž Sony MD'";
      Restart = "always";
      RestartSec = 10;
      DynamicUser = true;
    };
  };

  networking.firewall.enable = false;

  services.home-assistant = {
    enable = true;
    extraComponents = [
      # Components required to complete the onboarding
      "analytics"
      "google_translate"
      "met"
      "radio_browser"
      "shopping_list"
      # Recommended for fast zlib compression
      # https://www.home-assistant.io/integrations/isal
      "isal"
      # ZigBee
      "zha"

      "brother"
      "ipp"
      "prometheus"
      "rpi_power"
      "shelly"

      "motioneye"
      "vlc_telnet"
    ];
    config = {
      # Includes dependencies for a basic setup
      # https://www.home-assistant.io/integrations/default_config/
      default_config = {};

      prometheus = {};          # enable prometheus
    };
  };

  services.openssh.enable = true;

  services.udisks2.enable = false;

  services.comin = {
    enable = true;
    package = inputs.comin.packages.${pkgs.stdenv.hostPlatform.system}.comin.override { git = pkgs.gitMinimal; };
    remotes = [{
      name = "origin";
      url = "https://github.com/wentasah/nix-conf.git";
      branches.main = {
        name = "stable";
      };
      poller.period = 7 * 24 * 3600; # weekly
    }];
    retention = {
      deployment_boot_entry_capacity = 2;
      deployment_successful_capacity = 2;
      deployment_any_capacity = 2;
    };
  };

  # Reboot at night if comin says so
  systemd.services.reboot-if-updated = {
    description = "Reboot if comin deployment requires it";
    serviceConfig.Type = "oneshot";
    path = [ config.services.comin.package pkgs.jq ];
    script = ''
      if [[ "$(comin status --json | jq .need_to_reboot)" = true ]]; then
        echo "comin requires reboot - rebooting"
        systemctl reboot
      fi
    '';
  };
  systemd.timers.reboot-if-updated = {
    wantedBy = [ "timers.target" ];
    timerConfig.OnCalendar = "*-*-* 03:30:00";
  };

  users = {
    users.wsh = {
      isNormalUser = true;
      extraGroups = [ "wheel" ];
    };
  };

  hardware.enableRedistributableFirmware = true;
  system.stateVersion = "24.11";
}
