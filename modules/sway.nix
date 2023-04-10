{ config, pkgs, ... }:
{
  xsession = {
    preferStatusNotifierItems = true;
  };

  wayland.windowManager.sway = {
    enable = true;
    systemdIntegration = true;
  };

  home.packages = with pkgs; [
    brightnessctl
    cantarell-fonts
    i3status-rust font-awesome_4 powerline-fonts
    swaylock
    wev
    waybar
    networkmanagerapplet # need for tray icons
    wdisplays
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
}
