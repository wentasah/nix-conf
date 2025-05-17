{ config, pkgs, lib, ... }:
{
  wayland.windowManager.hyprland = {
    enable = true;
    plugins = [
      pkgs.hyprlandPlugins.hyprscrolling
    ];
    settings = {
      source = "~/.config/hypr/hyprland_local.conf";
    };
  };

  home.packages = with pkgs; [
    quintom-cursor-theme
    hypridle
  ];

  #services.xsettingsd.enable = true;
}
