{ pkgs ? import <nixpkgs> { } }:
with pkgs;
stdenv.mkDerivation rec {
  pname = "unfs3";
  version = "0.9.22";
  src = fetchFromGitHub {
    owner = "unfs3";
    repo = "unfs3";
    #rev = "unfs3-${version}";
    rev = "363d54ce3dbbed70225263d12f0e01646a0df93c"; # tirpc branch;
    sha256 = "sha256-iqRERT6/kZue6WX+hxXW4f+NUqQZUFh1r8GUmKfnDZc=";
  };

  nativeBuildInputs = [ autoconf automake yacc flex pkg-config ];
  buildInputs = [ libtirpc ];

  preConfigure = "./bootstrap";
}
