{ pkgs, ... }:
{
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
}
