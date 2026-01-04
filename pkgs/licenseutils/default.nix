{ pkgs ? import <nixpkgs> {}}:
with pkgs;
stdenv.mkDerivation rec {
  pname = "licenseutils";
  version = "0.0.9";
  src = builtins.fetchTarball {
    url = "https://download.savannah.gnu.org/releases/licenseutils/licenseutils-${version}.tar.gz";
    sha256 = "0868zbnfykra5y6iwc686sbjb5fd37i00sqfi5f0h9s9jjw47azg";
  };
  nativeBuildInputs = [
    pkg-config
    texinfo
    help2man
  ];
  buildInputs = [
    curl
    libpng
    glib
    sourceHighlight
    bashInteractive
    boost
  ];
  patches = [
    (fetchpatch {
      # https://savannah.nongnu.org/bugs/?55151
      name = "fix-build-with-glibc-2.28.patch";
      url = "https://savannah.nongnu.org/bugs/download.php?file_id=45565";
      sha256 = "1nm0fnz88p8nyxyw5sk2lc7wbwmd9j3zzli3yj06rki2g6924anw";
    })
    (fetchpatch {
      # https://savannah.nongnu.org/bugs/?59157
      url = "https://sources.debian.org/data/main/l/licenseutils/0.0.9-5/debian/patches/fix-download-followlocation.patch";
      sha256 = "1n9s0sd1rcy7pjv0hp03zlkqkxah44a33nmfg7dk8qkzrgwvjhq2";
    })
    (fetchpatch2 {
      url = "https://sources.debian.org/data/main/l/licenseutils/0.0.9-8.1/debian/patches/gcc-15.patch";
      hash = "sha256-NYNoQ0uTCYCaGt2WobgyUmoztuZv7z9J1T24MMdyg9g=";
    })
  ];
  postPatch = ''
      substituteInPlace src/lu-sh.in --replace /bin/bash "${bashInteractive}/bin/bash"
    '';
  dontStrip = true;
  NIX_CFLAGS_COMPILE = "-ggdb -Og";
}
