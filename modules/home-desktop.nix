{ config, pkgs, lib, ... }:
# Home manager configuration common to all my desktops. Graphical tools, etc.
{
  imports = [
    ./xkb-wsh-home.nix
    ./audio.nix
  ];
  home.packages = with pkgs; let
    xdot' = xdot.overrideAttrs (old: {
      version = "1.4wsh";
      src = fetchFromGitHub {
        owner = "jrfonseca";
        repo = "xdot.py";
        hash = "sha256-fWPltgpFHc43kB5ldYkPVFzikPWGu/yDyqwRRMxr93Y=";
        rev = "2a68b2f303f477d493787bb4393c3a382c236405";
        # date = "2024-11-24T19:37:17Z";
      };
    });
  in [
    arandr
    audacity
    blender
    # ((blender.withPackages (p: [ p.pyclothoids p.scenariogeneration ])).overrideAttrs { pname = "blender"; }) # broken - blender currently uses python3.11 and scipy fails to build for it
    # carla # broken 2025-06-20
    drawio
    firefox
    (flameshot.override { enableWlrSupport = true; })
    freecad
    ghostty
    gimp
    (gnuplot_qt.override { withCaca = true; })
    gtkterm
    handbrake
    hotspot
    inkscape
    kdePackages.kdenlive
    kdePackages.okular
    kdiff3
    keepassxc
    kernelshark
    kicad-small
    kitty
    kooha
    krita
    libreoffice-fresh libreoffice-fresh.unwrapped.jdk
    meld
    mission-center
    musescore
    okteta
    pavucontrol
    pdfpc
    qpwgraph
    rustdesk-flutter
    screenkey
    shotcut
    smplayer mpv mplayer
    solvespace
    sqlitebrowser
    thunderbird
    video-trimmer
    vlc
    wmctrl
    xclip
    xdot'
    xdotool
    xdragon
    xournalpp
    yubioath-flutter
    zynaddsubfx
  ];

  home.pointerCursor = {
    gtk.enable = true;          # needs home.gtk.enable to be true
    name = "Quintom_Ink";
    package = pkgs.quintom-cursor-theme;
    size = 24;
  };
}
