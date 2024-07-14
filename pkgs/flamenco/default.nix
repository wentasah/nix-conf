{ stdenv
, fetchurl
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "flamenco";
  version = "3.5";
  src = fetchurl {
    url = "https://flamenco.blender.org/downloads/flamenco-${finalAttrs.version}-linux-amd64.tar.gz";
    hash = "sha256-ePbmR/s1Euc/GYWulH1QtCi52YMOy3X8C/THqBRkb54=";
  };

  installPhase = ''
    runHook preInstall

    tar xf $src
    mkdir -p $out/bin
    mv flamenco-${finalAttrs.version}-linux-amd64/* $out
    (cd $out/bin && ln -s ../flamenco-manager ../flamenco-worker .)

    runHook postInstall
  '';
})
