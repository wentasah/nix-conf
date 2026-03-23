{ pkgs ? import <nixpkgs> {} }:

let
  lexicon-wrapper = pkgs.writeScript "lexicon-wrapper" ''
    #! ${pkgs.stdenv.shell}
    export LD_LIBRARY_PATH=/opt/Lingea/Lexicon5/syst:$LD_LIBRARY_PATH
    exec /opt/Lingea/Lexicon5/Lexicon "$@"
    #/opt/Lingea/Lexicon5/LucGUI "$@"
  '';
in
pkgs.buildFHSEnv {
    name = "lexicon";
    multiArch = true;
    multiPkgs = pkgs: (with pkgs;
      [
        alsa-lib
        fontconfig
        freetype
        udev
        libx11
        libxext
        libxft
        libxmu
        libxt
        libxml2
        zlib

        # for LucGUI (dictionary activation, commented above)
        xorg.libXrender
      ]);
    runScript = "${lexicon-wrapper}";
}
