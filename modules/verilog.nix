{ pkgs, ... }:
let
  svlangserver = pkgs.callPackage ../pkgs/svlangserver.nix { };
  svls = pkgs.callPackage ../pkgs/svls.nix { };
  veridian = pkgs.callPackage ../pkgs/veridian { };
in
{
  home.packages = [
    pkgs.sv-lang
    pkgs.verible
    svlangserver
    svls
    veridian
  ];
}
