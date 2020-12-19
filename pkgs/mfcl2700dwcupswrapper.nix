{ stdenv, fetchurl, dpkg, makeWrapper, coreutils, gnugrep, gnused, perl, mfcl2700dwlpr }:

stdenv.mkDerivation rec {
  pname = "mfcl2700dwcupswrapper";
  version = "3.2.0-1";

  src = fetchurl {
    url = "https://download.brother.com/welcome/dlf101792/${pname}-${version}.i386.deb";
    sha256 = "1rx9hq5iwj8rlgrv6k13ji1fhh8z2lrd665qbihdavj30vn84y05";
  };

  nativeBuildInputs = [ dpkg makeWrapper ];

  phases = [ "installPhase" ];

  installPhase = ''
    dpkg-deb -x $src $out

    basedir=${mfcl2700dwlpr}/opt/brother/Printers/MFCL2700DW
    dir=$out/opt/brother/Printers/MFCL2700DW

    substituteInPlace $dir/cupswrapper/brother_lpdwrapper_MFCL2700DW \
      --replace /usr/bin/perl ${perl}/bin/perl \
      --replace "basedir =~" "basedir = \"$basedir\"; #" \
      --replace "PRINTER =~" "PRINTER = \"MFCL2700DW\"; #"

    substituteInPlace $dir/cupswrapper/paperconfigml1 \
      --replace /usr/bin/perl ${perl}/bin/perl

    wrapProgram $dir/cupswrapper/brother_lpdwrapper_MFCL2700DW \
      --prefix PATH : ${stdenv.lib.makeBinPath [ coreutils gnugrep gnused ]}

    mkdir -p $out/lib/cups/filter
    mkdir -p $out/share/cups/model

    ln $dir/cupswrapper/brother_lpdwrapper_MFCL2700DW $out/lib/cups/filter
    ln $dir/cupswrapper/brother-MFCL2700DW-cups-en.ppd $out/share/cups/model
  '';

  meta = {
    description = "Brother MFC-L2700DW CUPS wrapper driver";
    homepage = "http://www.brother.com/";
    license = stdenv.lib.licenses.gpl2;
    platforms = [ "x86_64-linux" "i686-linux" ];
    maintainers = [
      # stdenv.lib.maintainers.xeji
    ];
  };
}
