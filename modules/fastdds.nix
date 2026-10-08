{ config, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    fastdds
    fastcdr
    foonathan-memory
    fastddsgen
  ];

  # Without this cmake cannot find fastcdr includes
  environment.pathsToLink = [ "/include" ];
}
