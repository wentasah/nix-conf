{ stdenv
, lib
, fetchurl
, dpkg
, makeWrapper
, electron
, genericUpdater, writeShellScript, libxml2
}:
stdenv.mkDerivation rec {
  pname = "foxglove-studio";
  version = "2.9.0";

  src = fetchurl {
    url = "https://get.foxglove.dev/desktop/latest/foxglove-studio-${version}-linux-amd64.deb";
    hash = "sha256-nPX0YAO9alw0E7s2ofwLYgFLRZe+rEqqWXSa6pNgoGo=";
  };

  nativeBuildInputs = [ dpkg makeWrapper ];

  dontUnpack = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    dpkg -x $src $out
    mv $out/usr/* $out/
    rmdir $out/usr

    runHook postInstall
  '';

  postFixup = ''
    makeWrapper ${electron}/bin/electron $out/bin/${pname} \
      --add-flags "'$out/opt/Foxglove Studio/resources/app.asar'" \
      --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath [ stdenv.cc.cc ]}" \
      --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto --enable-features=WaylandWindowDecorations}}"
  '';

  passthru.updateScript = genericUpdater {
    versionLister = writeShellScript "foxglove-versionLister" ''
      curl https://foxglove.dev/download \
        | ${libxml2}/bin/xmllint --xpath 'string(//a[@class="download_downloadButton__XUA_h"]/@href)' - \
        | grep -Eo '[0-9]+\.[0-9]+\.[0-9]+'
    '';
  };
}
