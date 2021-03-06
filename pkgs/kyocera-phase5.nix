{ stdenv, dpkg, fetchzip, lib, cups, autoPatchelfHook }:

let
  version = "2018.08.29";
  version_ = builtins.replaceStrings ["."] ["_"] version;
  platform =
    if stdenv.hostPlatform.system == "x86_64-linux" then "amd64"
    else if stdenv.hostPlatform.system == "i686-linux" then "i386"
         else throw "Unsupported system: ${stdenv.hostPlatform.system}";
in
stdenv.mkDerivation {
  pname = "kyocera-phase5";
  inherit version;
  src = fetchzip {
    url = "https://www.kyoceradocumentsolutions.eu/content/download-center/eu/drivers/all/KyoceraLinux_Phase5_${version_}_zip.download.zip";
    sha256 = "0n86820v9by2fdarz2fhhpbk2mw92wbm23pcy9hdf2djqs47zn80";
  };

  nativeBuildInputs = [ dpkg autoPatchelfHook ];
  buildInputs = [
    cups
    #(python2.withPackages (ps: with ps; [ pypdf2 reportlab ]))
  ];

  installPhase = ''
    tar xf KyoceraLinux-Phase5-${version}.tar.gz
    dpkg-deb -x Debian/EU/kyodialog_${platform}/kyodialog_5.0-0_${platform}.deb deb

    install -D -t $out/lib/cups/filter deb/usr/lib/cups/filter/*

    # Don't include kyofilter_pre_F. Its purpose seems to be to just
    # add watermarks. It's python2 only and depends on insecure
    # python2 packages.
    rm $out/lib/cups/filter/kyofilter_pre_F

    mkdir -p $out/share/cups/model/Kyocera
    cd deb/usr/share/kyocera5/ppd5
    for i in *.ppd; do
      #sed -i $i -e "s,/usr/lib/cups/filter/,$out/lib/cups/filter/,g"
      # Do not use absolute paths in PPDs - when PPD is copied (by cups) to /etc, the path gets stale
      sed -i $i -e "s,/usr/lib/cups/filter/,,g"
      # Remove all references to the excluded filter (typically: *cupsPreFilter: "application/pdf 0 kyofilter_pre_F")
      sed -i $i -e "/kyofilter_pre_F/d"
      cp $i $out/share/cups/model/Kyocera
    done;
  '';

  meta = with lib; {
    description = "CUPS drivers for several Kyocera TASKalfa 3252ci and similar printers";
    homepage = "https://www.kyoceradocumentsolutions.eu/en/support/downloads.name-L2V1L2VuL21mcC9UQVNLQUxGQTMyNTJDSQ==.html#tab=driver";
    license = licenses.unfree;
    platforms = platforms.linux;
  };
}
