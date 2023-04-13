{ config, pkgs, ... }:
{
  imports = [
    ./dunst.nix
  ];

  xsession = {
    enable = true;
    scriptPath = ".xsession-hm";
    numlock.enable = true;
    windowManager.command = "${pkgs.i3}/bin/i3";
#     windowManager.i3 = {
#       enable = true;
#       config = null; # Do not generate config with home-manager
#       extraConfig = "${builtins.readFile "${config.home.homeDirectory}/.i3/config"}";
#     };
  };

  services.network-manager-applet.enable = true;

  systemd.user.services.network-manager-applet.Service = {
    # Handle crashes after xrandr or i3 restarts: https://github.com/NixOS/nixpkgs/issues/99197
    Restart = "on-failure";
    RestartSec = 5;
  };

  systemd.user.services = {
    parcellite = {
      Unit = {
        Description = "Parcellite";
        After = [ "graphical-session-pre.target" ];
        PartOf = [ "graphical-session.target" ];
      };

      Install = { WantedBy = [ "graphical-session.target" ]; };

      Service = {
        ExecStart = "${pkgs.parcellite}/bin/parcellite";
        # Handle crashes after xrandr or i3 restarts: https://github.com/NixOS/nixpkgs/issues/99197
        Restart = "on-failure";
        RestartSec = 5;
      };
    };
  };

  home.packages = with pkgs; [
    autorandr
    brightnessctl
    cantarell-fonts
    i3status-rust font-awesome_4 powerline-fonts
    rofi
    xss-lock
    picom # for removal of tearing effects (https://github.com/NixOS/nixpkgs/issues/142225)
    hsetroot # for setting background under picom (https://wiki.archlinux.org/title/Picom#Unable_to_change_the_background_color_with_xsetroot)
  ];

  home.keyboard = {
    layout = "us,cz";
    variant = ",ucw";
    options = [
      "compose:ralt"
      "grp:caps_switch"
      "terminate:ctrl_alt_bksp"
      "wsh:caps_arrows"
    ];
  };
}
