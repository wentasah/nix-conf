{ pkgs ? import <nixpkgs> {} }:

let
  lexicon-wrapper = pkgs.writeScript "lexicon-wrapper" ''
    #! ${pkgs.stdenv.shell}
    export LD_LIBRARY_PATH=/opt/Lingea/Lexicon5/syst:$LD_LIBRARY_PATH
    exec /opt/Lingea/Lexicon5/Lexicon "$@"
    #/opt/Lingea/Lexicon5/LucGUI "$@"
  '';
in
pkgs.buildFHSUserEnvBubblewrap {
    name = "lexicon";
    multiPkgs = pkgs: (with pkgs;
      [
        alsaLib
        fontconfig
        freetype
        udev
        xorg.libX11
        xorg.libXext
        xorg.libXft
        xorg.libXmu
        xorg.libXt
        libxml2
        zlib

        # for LucGUI (dictionary activation, commented above)
        xorg.libXrender
      ]);
    runScript = "${lexicon-wrapper}";
}
