{ config, pkgs, ... }:
let
  fastdds = pkgs.callPackage ../pkgs/fastdds { };
  fastddsgen = pkgs.callPackage ../pkgs/fastdds/fastddsgen.nix { };
in
{
  environment.systemPackages = [
    fastdds fastdds.fastcdr fastdds.foonathan-memory
    fastddsgen
  ];

  # Without this cmake cannot find fastcdr includes
  environment.pathsToLink = [ "/include" ];
}
