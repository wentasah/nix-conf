{ config, pkgs, ... }:
{
  home.packages = with pkgs; [
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
    open-sans
    roboto
    roboto-slab
    source-sans
    source-sans-pro
    source-serif
    source-serif-pro
  ];

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
