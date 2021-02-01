{ stdenv, lib, buildFHSUserEnv, unzip, dpkg, gtk3, cairo, glib, webkitgtk }:
let
  debs = stdenv.mkDerivation {
    name = "stm32cubeide_debs";
    # Direct download URL is probably not available, because one has
    # to agree to the license.
    src = ./en.st-stm32cubeide_1.5.1_9029_20201210_1234_amd64.deb_bundle.sh.zip;
    unpackCmd = "mkdir tmp && ${unzip}/bin/unzip $curSrc -d tmp";
    installPhase = ''
      s=$(echo *.sh)
      sh "$s" --target ''${s%.sh} --noexec
      mkdir -p $out
      mv -v ''${s%.sh}/* $out
    '';
  };
  stm32cubeide = stdenv.mkDerivation {
    name = "stm32cubeide";
    version = "1.5.1";
    src = "${debs}/st-stm32cubeide-1.5.1-9029-20201210-1234_amd64.deb";

    nativeBuildInputs = [ dpkg ];

    unpackCmd = "mkdir unpacked && dpkg -x $curSrc unpacked";

    dontAutoPatchelf = true;

    installPhase = ''
      mkdir -p $out
      mv * $out
    '';
  };
in
buildFHSUserEnv {
  name = "stm32cubeide";

  targetPkgs = pkgs: with pkgs; [
    stm32cubeide
    gtk3 cairo glib webkitgtk
  ];

  runScript = ''
    ${stm32cubeide.outPath}/opt/st/stm32cubeide_1.5.1/stm32cubeide
  '';
}
