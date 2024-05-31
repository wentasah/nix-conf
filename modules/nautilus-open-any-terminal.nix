{ pkgs, ... }:
{
  home.packages = [ pkgs.nautilus-open-any-terminal ];
  dconf.settings = {
    "com/github/stunkymonkey/nautilus-open-any-terminal" = {
      terminal = "kitty";
    };
  };
}
