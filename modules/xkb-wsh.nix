# Adapted from nixpkgs/nixos/modules/services/x11/extra-layouts.nix
{ config, pkgs, ... }:
let
  xkb_patched = pkgs.callPackage ../pkgs/wsh-xkb-config {};
in
{
  environment.sessionVariables = {
    # runtime override supported by multiple libraries e. g. libxkbcommon
    # https://xkbcommon.org/doc/current/group__include-path.html
    XKB_CONFIG_ROOT = "${xkb_patched}/etc/X11/xkb";
  };

  services.xserver = {
    xkbDir = "${xkb_patched}/etc/X11/xkb";
    exportConfiguration = config.services.xserver.displayManager.startx.enable
                          || config.services.xserver.displayManager.sx.enable;
  };
}
