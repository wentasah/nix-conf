{ lib, writeShellScriptBin, julia, zlib, openssl, qt5, freetype, libpng, stdenv, libiconvReal }:
let
  # Libraries needed by binary artifacts
  libs = [
    freetype
    libiconvReal
    libpng
    openssl
    qt5.qtbase
    stdenv.cc.cc.lib
    zlib
  ];
in
writeShellScriptBin "julia" ''
  # Set variables for nix-ld
  export NIX_LD_LIBRARY_PATH=${lib.makeLibraryPath libs}
  export NIX_LD=${stdenv.cc.libc}/lib/ld-linux-x86-64.so.2
  export LD_LIBRARY_PATH="$LD_LIBRARY_PATH''${LD_LIBRARY_PATH:+:}/run/opengl-driver/lib"
  exec ${julia}/bin/julia "$@"
''
