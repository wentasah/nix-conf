{ config, pkgs, ... }:
{
  imports = [
    ./dunst.nix
  ];

  xsession = {
    preferStatusNotifierItems = true;
  };

  wayland.windowManager.sway = {
    enable = true;
    config = null; # don't generate the config automatically
    extraConfigEarly = ''
      include config.local
    '';
    systemdIntegration = true;
    extraSessionCommands = ''
      PATH=$HOME/bin:$PATH
    '';
    wrapperFeatures = {
      base = true;
      gtk = true;
    };
  };

  home.packages = with pkgs; [
    brightnessctl
    cantarell-fonts
    swappy grim slurp
    i3status-rust
    font-awesome_4
    powerline-fonts
    networkmanagerapplet # need for tray icons
    swaylock
    waybar
    wdisplays
    wev
    wl-clipboard
    wlr-randr
    wofi
    rofi
    xdg-desktop-portal-wlr
    #     (swaylock.overrideAttrs(old: {
    #       src = fetchFromGitHub {
    #         owner = "swaywm";
    #         repo = "swayidle";
    #         rev = "068942751ba459ef3b9ba0ec8eddf9f6f212c4d7";
    #         # date = 2020-11-06T11:38:15+01:00;
    #         sha256 = "1ml2n1rp8simpd2y4ff1anx2vj89f3a6dhfz8m2hdan749vwnxvk";
    #       };
    #       buildInputs = old.buildInputs ++ [ systemd ];
    #     }))
  ];

  services.clipman.enable = true;
  services.network-manager-applet.enable = true;

  # Define the same systemd targets as home-manager, but without requiring managing
  systemd.user.targets.sway-session = {
    Unit = {
      Description = "sway compositor session";
      Documentation = [ "man:systemd.special(7)" ];
      BindsTo = [ "graphical-session.target" ];
      Wants = [ "graphical-session-pre.target" ];
      After = [ "graphical-session-pre.target" ];
    };
  };

  systemd.user.targets.tray = {
    Unit = {
      Description = "Home Manager System Tray";
      Requires = [ "graphical-session-pre.target" ];
    };
  };
}
