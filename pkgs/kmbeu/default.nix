{ stdenv, fetchurl, lib, perl }:

stdenv.mkDerivation {
  pname = "konica-minolta-bizhub";
  version = "1.24";
  src = fetchurl {
    name = "KMbeuUXv1_24_multi_language.tar.gz";
    url = "https://dl.konicaminolta.eu/cs/?tx_kmanacondaimport_downloadproxy[fileId]=79da0f659ac2191cf88560aee21df50d&tx_kmanacondaimport_downloadproxy[documentId]=128230&tx_kmanacondaimport_downloadproxy[system]=KonicaMinolta&tx_kmanacondaimport_downloadproxy[language]=CS&type=1558521685";
    sha256 = "029ff7mw2snz5nb49hgnv90fqr64nsxbnpw8p0byw8a1p5v85l06";
  };

  buildInputs = [ perl ];

  installPhase = ''
    tar xf $src
    cd KMbeuUXv1_24_multi_language
    install -D -t $out/share/cups/model *.ppd
    install -D -t $out/lib/cups/filter KMbeuEmpPS.pl KMbeuEnc.pm
  '';

  meta = with lib; {
    description = "CUPS drivers for several Konica-Minolta bizhub printers";
    homepage = "https://www.konicaminolta.cz/cs-cz/hardware/kancelarsky-tisk/bizhub-c258";
    license = licenses.unfree;
    platforms = platforms.linux;
  };
}
