{ pkgs, ... }:
let
  svlangserver = pkgs.callPackage ../pkgs/svlangserver.nix { };
in
{
  home.packages = [
    pkgs.sv-lang
    pkgs.verible
    svlangserver
    pkgs.svls
    pkgs.veridian
  ];
}
