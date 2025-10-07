{ pkgs, ... }:
{
  home.packages = [
    # pkgs.sv-lang # broken <2025-10-07 Tue>
    pkgs.verible
    pkgs.svlangserver
    pkgs.svls
    pkgs.veridian
  ];
}
