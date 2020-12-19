{ pkgs ? import <nixpkgs> {} }:
with pkgs;
stdenv.mkDerivation rec {
  pname = "cppreference";
  version = "20190607";
  src = builtins.fetchurl {
    url = "https://upload.cppreference.com/mwiki/images/1/16/html_book_${version}.tar.xz";
    sha256 = "0va81rggdfiqrzgqfn87ld8shnp9lbqqbmr2w2i4iis9lyxb55wg";
  };
  buildCommand = ''
    mkdir -p $out/share/doc/${pname}
    tar -C $out/share/doc/${pname} -xf ${src}
  '';
}
