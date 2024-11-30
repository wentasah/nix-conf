{ config, pkgs, ... }:
{
  home.packages = with pkgs; [
    emacs-all-the-icons-fonts
    lato
    libertine # For images consistency with ACM latex template
    open-sans
    roboto
    roboto-slab
    source-sans
    source-sans-pro
    source-serif
    source-serif-pro
    iosevka
  ] ++ (if pkgs ? nerd-fonts then [
    nerd-fonts.dejavu-sans-mono
    nerd-fonts.iosevka
    nerd-fonts.jetbrains-mono
    nerd-fonts.symbols-only
    nerd-fonts.noto
    nerd-fonts.roboto-mono
    nerd-fonts.sauce-code-pro
  ] else [
    # Remove after switching to 25.05
    (nerdfonts.override {
      fonts = [
        "DejaVuSansMono"
        "Iosevka"
        "JetBrainsMono"
        "NerdFontsSymbolsOnly"
        "Noto"
        "RobotoMono"
        "SourceCodePro"
      ];
    })
  ]);

#   xdg.configFile = {
#     "fontconfig/conf.d/99-my-fonts.conf".text = ''
#       <?xml version='1.0'?>
#       <!DOCTYPE fontconfig SYSTEM 'urn:fontconfig:fonts.dtd'>
#       <fontconfig>
#         <!-- Default fonts -->
#         <alias binding="same">
#           <family>monospace</family>
#           <prefer>
#             <family>Iosevka Nerd Font Mono</family>
#           </prefer>
#         </alias>
#       </fontconfig>
#     '';
#   };
}
