{ stdenv, dpkg, fetchzip, lib, cups, autoPatchelfHook }:

let
  version = "2024-05-21";
  version_ = builtins.replaceStrings ["-"] [""] version;
  kyodialogVersion = "9.4";
  platform =
    if stdenv.hostPlatform.system == "x86_64-linux" then "amd64"
    else if stdenv.hostPlatform.system == "i686-linux" then "i386"
         else throw "Unsupported system: ${stdenv.hostPlatform.system}";
in
stdenv.mkDerivation {
  pname = "kyocera-driver";
  inherit version;
  src = fetchzip {
    url = "https://www.kyoceradocumentsolutions.eu/content/dam/download-center-cf/eu/drivers/all/Linux_Universal_Driver_zip.download.zip";
    hash = "sha256-AsteEtb792NQxPD+ZDDmJqi0hVnGIg2dAhCVpLyjGiw=";
    # date = "2025-11-19T09:15:37+0100";
  };

  nativeBuildInputs = [ dpkg autoPatchelfHook ];
  buildInputs = [
    cups
    #(python2.withPackages (ps: with ps; [ pypdf2 reportlab ]))
  ];

  installPhase = ''
    tar xf KyoceraLinuxPackages-${version_}.tar.gz
    dpkg-deb -x Debian/EU/kyodialog_${platform}/kyodialog_${kyodialogVersion}-0_${platform}.deb deb

    install -D -t $out/lib/cups/filter deb/usr/lib/cups/filter/*

    mkdir -p $out/share/kyocera${kyodialogVersion}/
    cd deb/usr/share/kyocera${kyodialogVersion}/ppd${kyodialogVersion}
    for i in *.ppd; do
      #sed -i $i -e "s,/usr/lib/cups/filter/,$out/lib/cups/filter/,g"
      # Do not use absolute paths in PPDs - when PPD is copied (by cups) to /etc, the path gets stale
      sed -i $i -e "s,/usr/lib/cups/filter/,,g"
      # Remove all references to the excluded filter (typically: *cupsPreFilter: "application/pdf 0 kyofilter_pre_F")
      sed -i $i -e "/kyofilter_pre_F/d"
      cp $i $out/share/kyocera${kyodialogVersion}/
    done;
  '';

  meta = with lib; {
    description = "CUPS drivers for several Kyocera TASKalfa 3252ci and similar printers";
    homepage = "https://www.kyoceradocumentsolutions.eu/en/support/downloads.name-L2V1L2VuL21mcC9UQVNLQUxGQTMyNTJDSQ==.html#tab=driver";
    license = licenses.unfree;
    platforms = platforms.linux;
  };
}
