{ stdenv
, lib
, fetchurl
, dpkg
, makeWrapper
, electron
}:
stdenv.mkDerivation rec {
  pname = "foxglove-studio";
  version = "1.81.0";

  src = fetchurl {
    url = "https://github.com/foxglove/studio/releases/download/v${version}/foxglove-studio-${version}-linux-amd64.deb";
    hash = "sha256-Ocs0hlnlP2FSOux038wljjms85Z0YKVq66exGzaXQOE=";
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
}
