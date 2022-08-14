{ config, pkgs, lib, ... }:
{
  # Packages needed for Linux kernel compilation
  home.packages = with pkgs; [
    bc                          # For linux kernel compilation
    ncurses6.dev                # for Linux's make manuconfig
    openssl.dev                 # For linux kernel compilation
  ];
}
