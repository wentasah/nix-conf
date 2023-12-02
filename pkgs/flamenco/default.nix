{ stdenv
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "flamenco";
  version = "3.3";
  src = fetchTarball {
    url = "https://flamenco.blender.org/downloads/flamenco-${finalAttrs.version}-linux-amd64.tar.gz";
    sha256 = "sha256:0k94s6rsrwaspck8vz124rlbwiqaml65kn84ljlwvwwzn4vmgpx9";
  };

  installPhase = ''
    runHook preInstall

    mkdir $out $out/bin
    cp -r $src/* $out
    (cd $out/bin && ln -s ../flamenco-manager ../flamenco-worker .)

    runHook postInstall
  '';
})
