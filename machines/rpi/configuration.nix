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

  nix.settings.trusted-users = [ "root" "@wheel" ];

  environment.systemPackages = with pkgs; [
    kitty.terminfo
    mc
    vim
  ];

  systemd.services.librespot = {
    enable = true;
    after = [ "network.target" ];
    description = "librespot Spotify client";
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.librespot}/bin/librespot --name 'Věž Sony MD'";
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

  #services.spotifyd.enable = true;

  services.xserver.enable = true;
  services.xserver.desktopManager.kodi.enable = true;
  services.xserver.displayManager.autoLogin.enable = true;
  services.xserver.displayManager.autoLogin.user = "kodi";
  services.xserver.displayManager.lightdm.greeter.enable = false;

  # Define a user account
  users.extraUsers.kodi.isNormalUser = true;

  services.cage.enable = true;
  services.cage.program = "${pkgs.kodi-wayland}/bin/kodi-standalone";
  services.cage.user = "kodi";


  systemd.services.cage.wantedBy = [ "multi-user.target" ];

  users = {
    users.wsh = {
      isNormalUser = true;
      extraGroups = [ "wheel" ];
    };
  };

  hardware.enableRedistributableFirmware = true;
  system.stateVersion = "24.11";
}
