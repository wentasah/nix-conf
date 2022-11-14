{ config, pkgs, ... }:
{
  home.packages = with pkgs; [
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
    (nerdfonts.override {
      fonts = [
        "DejaVuSansMono"
        "DroidSansMono"
        "Iosevka"
        "Noto"
        "RobotoMono"
        "SourceCodePro"
      ];
    })
  ];

  xdg.configFile = {
    "fontconfig/conf.d/99-my-fonts.conf".text = ''
      <?xml version='1.0'?>
      <!DOCTYPE fontconfig SYSTEM 'urn:fontconfig:fonts.dtd'>
      <fontconfig>
        <!-- Default fonts -->
        <alias binding="same">
          <family>monospace</family>
          <prefer>
            <family>Iosevka Nerd Font Mono</family>
          </prefer>
        </alias>
      </fontconfig>
    '';
  };
}
