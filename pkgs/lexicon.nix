{ pkgs ? import <nixpkgs> {} }:

let
  lexicon-wrapper = pkgs.writeScript "lexicon-wrapper" ''
    #! ${pkgs.stdenv.shell}
    export LD_LIBRARY_PATH=/mnt/debian/opt/Lingea/Lexicon5/syst/lib0:$LD_LIBRARY_PATH
    exec /mnt/debian/opt/Lingea/Lexicon5/Lexicon "$@"
  '';
in
pkgs.buildFHSUserEnv {
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
      ]);
    runScript = "${lexicon-wrapper}";
}
