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
    # systemd.enable = true; # Stable requires the above, unstable warns about it. Switch to this for 23.11.
    extraSessionCommands = ''
      . /etc/set-environment
      . "${config.home.profileDirectory}/etc/profile.d/hm-session-vars.sh"
      # We want out services to have the same PATH as our session
      systemctl --user set-environment PATH=$PATH
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
    wdisplays
    wev
    wl-clipboard
    wl-mirror pipectl
    wlr-randr
    wofi
    way-displays
    rofi
    xdg-desktop-portal-wlr
    ydotool
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

  programs.waybar = {
    enable = true;
    systemd = {
      enable = true;
      target = "sway-session.target";
    };
  };
}
