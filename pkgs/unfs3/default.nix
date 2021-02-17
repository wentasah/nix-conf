{ pkgs ? import <nixpkgs> { } }:
with pkgs;
stdenv.mkDerivation rec {
  pname = "unfs3";
  version = "0.9.22";
  src = fetchFromGitHub {
    owner = "unfs3";
    repo = "unfs3";
    #rev = "unfs3-${version}";
    rev = "tirpc";
    sha256 = "0gs4h9z67lic5fvr8pjnycgszh98ark5fhwn6fwf331yvx3w8s2j";
  };

  nativeBuildInputs = [ autoconf automake yacc flex pkg-config ];
  buildInputs = [ libtirpc ];

  preConfigure = "./bootstrap";
}
