{ config, pkgs, ... }:
{
  home.packages = with pkgs; [
    isync
    oauth2ms
  ];
}
