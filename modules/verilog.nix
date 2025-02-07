{ pkgs, ... }:
{
  home.packages = [
    pkgs.sv-lang
    pkgs.verible
    pkgs.svlangserver
    pkgs.svls
    pkgs.veridian
  ];
}
