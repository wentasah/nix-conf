{ config, pkgs, ... }:
let
  fastdds = pkgs.callPackage ../pkgs/fastdds { };
in
{
  environment.systemPackages = [
    fastdds fastdds.fastcdr fastdds.foonathan-memory
  ];

  # Without this cmake cannot find fastcdr includes
  environment.pathsToLink = [ "/include" ];
}
