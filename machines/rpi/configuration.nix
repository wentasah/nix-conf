{ config, pkgs, lib, ... }:

{
  boot = {
    kernelPackages = pkgs.linuxKernel.packages.linux_rpi4;
    initrd.availableKernelModules = [ "xhci_pci" "usbhid" "usb_storage" ];
    loader = {
      grub.enable = false;
      generic-extlinux-compatible.enable = true;
    };
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
    nixPath = config.nix.settings.nix-path;
  };

  networking.hostName = "homeassistant";

  environment.systemPackages = with pkgs; [
    btop
    htop
    kitty.terminfo
    mc
    vim
  ];

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

  users = {
    users.wsh = {
      isNormalUser = true;
      extraGroups = [ "wheel" ];
    };
  };

  hardware.enableRedistributableFirmware = true;
  system.stateVersion = "24.11";
}
