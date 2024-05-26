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
    xkb.dir = "${xkb_patched}/etc/X11/xkb";
    exportConfiguration = config.services.xserver.displayManager.startx.enable
                          || config.services.xserver.displayManager.sx.enable;
  };

  nixpkgs.overlays = [
    (final: prev: {
      xorg = prev.xorg // {
        setxkbmap = prev.xorg.setxkbmap.overrideAttrs (attrs: {
          postInstall = attrs.postInstall + ''
            ln -sfn ${xkb_patched}/etc/X11 $out/share/X11
            ln -sfn ${xkb_patched}/share/man/man7/xkeyboard-config.7.gz $out/share/man/man7
          '';
        });
      };
    })
  ];
}
