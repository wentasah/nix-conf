{ config, pkgs, lib, ... }:

# I don't want to use xdg-desktop-portal-gnome, which is installed
# globally for users using Gnome. That portal makes GTK apps to start
# 20 seconds under sway etc.
let
  joinedPortals = pkgs.buildEnv {
    name = "xdg-portals";
    paths = with pkgs; [
      xdg-desktop-portal
      xdg-desktop-portal-gtk
      xdg-desktop-portal-wlr
    ];
    pathsToLink = [
      "/share/xdg-desktop-portal/portals"
      "/share/applications"
    ];
  };
in
{
  systemd.user.sessionVariables = {
    # Override global value
    XDG_DESKTOP_PORTAL_DIR = "${joinedPortals}/share/xdg-desktop-portal/portals";
  };
}
