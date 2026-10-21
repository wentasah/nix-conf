{ pkgs, ... }:
{
  home.packages = [
    pkgs.sv-lang
    pkgs.verible
    pkgs.svlangserver
    pkgs.svls
    # pkgs.veridian # broken <2026-09-13 Sun>
  ];
}
