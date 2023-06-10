{ config, pkgs, ... }:
{
  home.packages = with pkgs; [
    (isync.override { withCyrusSaslXoauth2 = true; })
    oauth2ms
  ];
}
