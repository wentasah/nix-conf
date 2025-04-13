{ config, pkgs, lib, ... }:
# Home manager configuration common to all my desktops. Graphical tools, etc.
{
  imports = [
    ../modules/xkb-wsh-home.nix
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
    ((blender.withPackages (p: [ p.pyclothoids p.scenariogeneration ])).overrideAttrs { pname = "blender"; })
    carla
    drawio
    firefox #-devedition-bin # I need devedition to use (currently) unrelease version of https://github.com/stsquad/emacs_chrome
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
    zynaddsubfx
  ];
}
