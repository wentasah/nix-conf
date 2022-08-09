{ pkgs ? import <nixpkgs> {} }:
with pkgs;
i3.overrideAttrs (old: rec {
  version = "4.15-281-g3b73edb5";
  src = fetchFromGitHub {
    owner = "i3";
    repo = "i3";
    rev = "ebcd1d43ea9fd08a1dbb1212fb61e42f05a22684";
    hash = "sha256-JGQW/9TdN48iyGMxRitPd4krXhb0qaLeGEfazFoL2J4=";
  };
  buildInputs = old.buildInputs ++ [ pcre2 ];
})
