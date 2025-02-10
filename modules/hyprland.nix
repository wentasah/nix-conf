{ config, pkgs, lib, ... }:
{
  wayland.windowManager.hyprland = {
    enable = true;
    plugins = [
      pkgs.hyprlandPlugins.hyprscroller
    ];
    settings = {
      source = "~/.config/hypr/local.conf";
    };
  };

  home.packages = with pkgs; [
    hyprlandPlugins.hyprscroller
  ];

  #services.xsettingsd.enable = true;
}
