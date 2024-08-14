{ config, pkgs, lib, ... }:
# Home manager configuration common to all my desktops. Graphical tools, etc.
{
  imports = [
  ];
  home.packages = with pkgs; [
    kooha
    handbrake
  ];
}
