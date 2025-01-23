{ config, pkgs, lib, ... }:
# Home manager configuration common to all my desktops. Graphical tools, etc.
{
  imports = [
  ];
  home.packages = with pkgs; [
    arandr
    audacity
    ((pkgs.blender.withPackages (p: [ p.pyclothoids p.scenariogeneration ])).overrideAttrs { pname = "blender"; })
    carla
    drawio
    firefox #-devedition-bin # I need devedition to use (currently) unrelease version of https://github.com/stsquad/emacs_chrome
    freecad
    ghostty
    gimp
    (gnuplot_qt.override { withCaca = true; })
    gtkterm
    handbrake
    hotspot
    inkscape
    kdenlive
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
    okular
    pavucontrol
    pdfpc
    qpwgraph
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
    xdotool
    xdragon
    xournalpp
  ];
}
