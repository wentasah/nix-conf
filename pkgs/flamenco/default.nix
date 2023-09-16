{ stdenv
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "flamenco";
  version = "3.2";
  src = fetchTarball {
    url = "https://flamenco.blender.org/downloads/flamenco-${finalAttrs.version}-linux-amd64.tar.gz";
    sha256 = "sha256:16jk0l8qv7h9j90knmd6avrc2x0ww3rwbfpsxj9m8n44jbyi1a60";
  };

  installPhase = ''
    runHook preInstall

    mkdir $out $out/bin
    cp -r $src/* $out
    (cd $out/bin && ln -s ../flamenco-manager ../flamenco-worker .)

    runHook postInstall
  '';
})
