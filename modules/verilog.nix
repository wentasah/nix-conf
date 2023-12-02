{ pkgs, ... }:
let
  svlangserver = pkgs.callPackage ../pkgs/svlangserver.nix { };
  svls = pkgs.callPackage ../pkgs/svls.nix { };
in
{
  home.packages = [
    pkgs.sv-lang
    pkgs.verible
    svlangserver
    svls
    pkgs.veridian
  ];
}
