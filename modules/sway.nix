{ config, pkgs, ... }:
{
  xsession = {
    preferStatusNotifierItems = true;
  };

  wayland.windowManager.sway = {
    enable = false;             # true collides with hand-written config
    systemdIntegration = true;
  };

  home.packages = with pkgs; [
    brightnessctl
    cantarell-fonts
    i3status-rust font-awesome_4 powerline-fonts
    networkmanagerapplet # need for tray icons
    swaylock
    waybar
    wdisplays
    wev
    wlr-randr
    wofi
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
}
