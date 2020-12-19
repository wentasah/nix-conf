{ pkgs ? import <nixpkgs> { } }:
with pkgs;
stdenv.mkDerivation rec {
  pname = "pod-mode";
  version = "1.03";
  src = fetchurl {
    url = "mirror://cpan/authors/id/S/SC/SCHWIGON/pod-mode/pod-mode-${version}.tar.gz";
    sha256 = "1psjnr3mxgs8ikzdn9wqk9iiy1c968ah39p7b8lprl449cl67i5g";
    # date = 2020-12-17T11:51:31+0100;
  };

  installPhase = "install -D -t $out/share/emacs/site-lisp pod-mode.el";
}
