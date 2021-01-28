{ pkgs ? import <nixpkgs> { } }:
with pkgs;
stdenv.mkDerivation rec {
  pname = "gtkterm";
  version = "1.1.1";
  src = fetchFromGitHub {
    owner = "Jeija";
    repo = "gtkterm";
    rev = "${version}";
    sha256 = "0s2cx8w1n8d37pl80gll5h6dyvbqrfcam8l4wmvnqqww9jml6577";
  };
  nativeBuildInputs = [
    meson ninja pkg-config
  ];

  buildInputs = [
    gtk3 vte libgudev
  ];
}
