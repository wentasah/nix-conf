{ pkgs, stdenv, fetchurl, dpkg, makeWrapper, coreutils, ghostscript, gnugrep, gnused, which, perl }:

stdenv.mkDerivation rec {
  pname = "mfcl2700dwlpr";
  version = "3.2.0-1";

  src = fetchurl {
    url = "https://download.brother.com/welcome/dlf101791/${pname}-${version}.i386.deb";
    sha256 = "1j6fgjfv6zzbzd01xy2997fkinaaljagvyykdr3hs8rvdc1j0ig8";
  };

  nativeBuildInputs = [ dpkg makeWrapper ];

  phases = [ "installPhase" ];

  installPhase = ''
    dpkg-deb -x $src $out

    dir=$out/opt/brother/Printers/MFCL2700DW

    substituteInPlace $dir/lpd/filter_MFCL2700DW \
      --replace /usr/bin/perl ${perl}/bin/perl \
      --replace "BR_PRT_PATH =~" "BR_PRT_PATH = \"$dir\"; #" \
      --replace "PRINTER =~" "PRINTER = \"MFCL2700DW\"; #"

    wrapProgram $dir/lpd/filter_MFCL2700DW \
      --prefix PATH : ${stdenv.lib.makeBinPath [
        coreutils ghostscript gnugrep gnused which
      ]}

    # need to use i686 glibc here, these are 32bit proprietary binaries
    interpreter=${pkgs.pkgsi686Linux.glibc}/lib/ld-linux.so.2
    patchelf --set-interpreter "$interpreter" $dir/inf/braddprinter
    patchelf --set-interpreter "$interpreter" $dir/lpd/brprintconflsr3
    patchelf --set-interpreter "$interpreter" $dir/lpd/rawtobr3
  '';

  meta = {
    description = "Brother MFC-L2700DW lpr driver";
    homepage = "http://www.brother.com/";
    license = stdenv.lib.licenses.unfree;
    platforms = [ "x86_64-linux" "i686-linux" ];
    maintainers = [
      #stdenv.lib.maintainers.wentasah
    ];
  };
}
