{ pkgs, ... }:
{
  # Default theme "gnome" doesn't work well under i3
  #   qt5.platformTheme = "gtk2";
  #   qt5.style = "gtk2";

  # Allow using "gtk2" theme in some applications
  environment.systemPackages = [
    pkgs.libsForQt5.qtstyleplugins
  ];
}
