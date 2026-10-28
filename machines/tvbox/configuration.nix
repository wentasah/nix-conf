{
  modulesPath,
  inputs,
  lib,
  pkgs,
  ...
} @ args:
{
  imports = [
    ./disk-config.nix
    inputs.disko.nixosModules.disko
  ];

  hardware.facter.reportPath = ./facter.json;

  boot.loader.systemd-boot.enable = true;
  networking.hostName = "tvbox";
  services.openssh.enable = true;

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
  };

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

  users.users.root.openssh.authorizedKeys.keys =
  [
    # change this to your ssh key
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAII1uS4dwnJJtix6/UYXC4z5NGWIC9UqNSojQnL56zEFd wsh@steelpick (passwd)"
  ] ++ (args.extraPublicKeys or []); # this is used for unit-testing this module and can be removed if not needed

  system.stateVersion = "26.05";
}
