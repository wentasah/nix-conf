{ config, pkgs, ... }:
let
  # Inspiration: https://github.com/NixOS/nixpkgs/issues/108480#issuecomment-1115108802
  isync-oauth2 = with pkgs; buildEnv {
    name = "isync-oauth2";
    paths = [ isync ];
    pathsToLink = ["/bin"];
    nativeBuildInputs = [ makeWrapper ];
    postBuild = ''
        wrapProgram "$out/bin/mbsync" \
          --prefix SASL_PATH : "${cyrus_sasl}/lib/sasl2:${cyrus-sasl-xoauth2}/lib/sasl2"
      '';
  };
in
{
  home.packages = with pkgs; [
    isync-oauth2 oauth2ms
  ];
}
