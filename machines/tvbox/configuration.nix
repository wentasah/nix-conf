{
  modulesPath,
  inputs,
  config,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    ./disk-config.nix
    inputs.disko.nixosModules.disko
  ];

  hardware.facter.reportPath = ./facter.json;

  boot.loader.systemd-boot.enable = true;
  networking.hostName = "tvbox";
  networking.dhcpcd.enable = false;
  networking.resolvconf.enable = false;
  services.openssh.enable = true;
  services.openssh.startWhenNeeded = true; # socket activation; don't delay boot
  systemd.network.wait-online.timeout = 0; # don't wait for being online
  systemd.services.NetworkManager-wait-online.enable = false;

  i18n.defaultLocale = "cs_CZ.UTF-8";
  time.timeZone = "Europe/Prague";

  environment.systemPackages = map lib.lowPrio (with pkgs; [
    curl
    firefox
    gitMinimal
    kitty.terminfo
    kodi-wayland
  ]);

  programs.yazi.enable = true;

  documentation.nixos.enable = false;

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
    persistent = true;
  };
  systemd.timers.nix-gc.timerConfig.WakeSystem = true;

  system.autoUpgrade = {
    enable = true;
    flake = "github:wentasah/nix-conf";
    flags = [ "--update-input" "nixpkgs" "--no-write-lock-file" ];
    dates = "03:00";
    persistent = false; # upgrade only at night
    allowReboot = true;
    rebootWindow = { lower = "01:00"; upper = "06:00"; };
  };
  systemd.timers.nixos-upgrade.timerConfig.WakeSystem = true;
  # Prevent suspend while upgrading (the inhibitor is killed with the
  # service's cgroup when the upgrade finishes)
  systemd.services.nixos-upgrade.script = lib.mkBefore ''
    ${config.systemd.package}/bin/systemd-inhibit --what=sleep:idle --why="NixOS upgrade" ${pkgs.coreutils}/bin/sleep infinity &
  '';

  # Enable the COSMIC login manager
  services.displayManager.cosmic-greeter.enable = true;

  # Enable the COSMIC desktop environment
  services.desktopManager.cosmic.enable = true;

  users.users.tv = {
    isNormalUser = true;
    extraGroups = [ "audio" "video" ];
  };

  services.displayManager.autoLogin = {
    enable = true;
    user = "tv";
  };

  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAII1uS4dwnJJtix6/UYXC4z5NGWIC9UqNSojQnL56zEFd wsh@steelpick (passwd)"
  ];

  system.stateVersion = "26.05";
}
