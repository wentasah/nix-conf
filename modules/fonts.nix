{ config, pkgs, ... }:
{
  home.packages = with pkgs; [
    adwaita-fonts
    emacs-all-the-icons-fonts
    iosevka
    lato
    libertine # For images consistency with ACM latex template
    nerd-fonts.dejavu-sans-mono
    nerd-fonts.iosevka
    nerd-fonts.jetbrains-mono
    nerd-fonts.noto
    nerd-fonts.roboto-mono
    nerd-fonts.sauce-code-pro
    nerd-fonts.symbols-only
    noto-fonts
    open-sans
    roboto
    roboto-slab
    source-sans
    source-sans-pro
    source-serif
    source-serif-pro
  ];
}
