{ stdenv
, lib
, fetchurl
, dpkg
, makeWrapper
, electron
, genericUpdater, writeShellScript
}:
stdenv.mkDerivation rec {
  pname = "foxglove-studio";
  version = "2.19.1";

  src = fetchurl {
    url = "https://get.foxglove.dev/desktop/latest/foxglove-studio-${version}-linux-amd64.deb";
    hash = "sha256-NjeGCrDGYb3z740BXZYAFdqpuijXOc6Mzs17hHiYWe4=";
  };

  nativeBuildInputs = [ dpkg makeWrapper ];

  dontUnpack = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    dpkg -x $src $out
    chmod 755 $out
    mv $out/usr/* $out/
    rmdir $out/usr
    mkdir $out/bin
    ln -s "$out/opt/Foxglove Studio/foxglove-studio" "$out/bin"

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
      curl https://docs.foxglove.dev/changelog/ \
      | xmllint --html --xpath 'string(//html/head/script[@type="application/ld+json"])' - 2>/dev/null \
      | jq -r '[.blogPost|.[].url|match("https://docs.foxglove.dev/changelog/foxglove/v(.*)")|.captures[0].string]|first'
    '';
  };
}
