{ config, pkgs, ... }:
{
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

  services.dunst = {
    enable = true;
    settings = {
      global = {
        follow = "mouse";
        geometry = "300x5-30+20";
        padding = 8;
        horizontal_padding = 8;
        frame_width = 3;
        frame_color = "#aaaaaa";
        idle_threshold = 120;
        font = "Cantarel 8";
        markup = "full";
        format = "<b>%s</b>\\n%b\\n%p";
        show_age_threshold = 60;
        word_wrap = true;
        max_icon_size = 32;
        icon_position = "left"; # Trying it
        dmenu = "${pkgs.rofi}/bin/rofi -dmenu -p Dunst";
        browser = "${pkgs.firefox}/bin/firefox";
      };
      # TODO: Replace with dunstctl
      shortcuts = {
        close = "mod4+Escape";
        history = "mod4+shift+Escape";
        context = "mod4+shift+period";
      };

      urgency_low = {
        background = "#222222";
        foreground = "#888888";
        timeout = 10;
        # Icon for notifications with low urgency, uncomment to enable
        #icon = /path/to/icon
      };

      urgency_normal = {
        background = "#285577";
        foreground = "#ffffff";
        timeout = 10;
        # Icon for notifications with normal urgency, uncomment to enable
        #icon = /path/to/icon
      };
      urgency_critical = {
        background = "#900000";
        foreground = "#ffffff";
        frame_color = "#ff0000";
        timeout = 0;
        # Icon for notifications with critical urgency, uncomment to enable
        #icon = /path/to/icon
      };
    };
  };

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
  ];
}
