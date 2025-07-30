{ stdenv, lib, buildFHSEnv, autoPatchelfHook, unzip, dpkg, gtk3,
  cairo, glib, webkitgtk_4_0, libusb1, bash, libsecret, alsa-lib, bzip2, openssl, udev, ncurses5, tlf, xorg, fontconfig, pcsclite, python3,
  requireFile
}:
let
  makeself-pkg = stdenv.mkDerivation {
    name = "stm32cubeide-makeself-pkg";
    # Direct download URL is probably not available, because one has
    # to agree to the license.
    src = requireFile rec {
      name = "en.st-stm32cubeide_1.5.1_9029_20201210_1234_amd64.sh.zip";
      sha256 = "01zjrrh3i88dcfgmqw0gsvy96qzwps9wnhx6pjl9lydyjd6dnzlv";
      url = "https://www.st.com/en/development-tools/stm32cubeide.html";
    };
    unpackCmd = "mkdir tmp && ${unzip}/bin/unzip -d tmp $curSrc";
    installPhase = ''
      sh st-stm32cubeide_1.5.1_9029_20201210_1234_amd64.sh --target $out --noexec
    '';
  };
  stm32cubeide = stdenv.mkDerivation {
    name = "stm32cubeide";
    version = "1.5.1";
    src = "${makeself-pkg}/st-stm32cubeide_1.5.1_9029_20201210_1234_amd64.tar.gz";
    dontUnpack = true;
    nativeBuildInputs = [ autoPatchelfHook ];
    buildInputs = [
      stdenv.cc.cc.lib # libstdc++.so.6
      libsecret
      alsa-lib
      bzip2
      openssl
      udev
      ncurses5
      tlf
      fontconfig
      pcsclite
      python3
    ] ++ (with xorg; [
      libX11
      libSM
      libICE
      libXrender
      libXrandr
      libXfixes
      libXcursor
      libXext
      libXtst
      libXi
    ]);
    autoPatchelfIgnoreMissingDeps = true; # libcrypto.so.1.0.0
    preferLocalBuild = true;
    installPhase = ''
      mkdir -p $out
      tar zxf $src -C $out
#       mkdir -p $out/bin
#       ln -s $out/opt/st/stm32cubeide_1.5.1/stm32cubeide $out/bin
    '';
  };
  stlink-server = stdenv.mkDerivation {
    name = "stlink-server-2.0.2-1";
    src = "${makeself-pkg}/st-stlink-server.2.0.2-1-linux-amd64.install.sh";
    nativeBuildInputs = [ autoPatchelfHook ];
    buildInputs = [ libusb1 ];
    unpackCmd = "sh $src --target dir --noexec";

    installPhase = ''
      ls -lR
      mkdir -p $out/bin
      cp stlink-server $out/bin
    '';
  };
in
# We use FHS environment because we want to run the compilers
# downloaded from the IDE and it is also needed by bundled SWT libraries.
buildFHSEnv {
  name = "stm32cubeide";

  targetPkgs = pkgs: with pkgs; [
    stm32cubeide
    gtk3 cairo glib
    webkitgtk_4_0               # needs insecure libsoup <2025-07-30 Wed>

    # These libraries are also needed in the FHS environment for
    # flashing/debugging to work. Having them as dependencies in
    # stm32cubeide is not sufficient.
    stdenv.cc.cc.lib # libstdc++.so.6
    libsecret
    alsa-lib
    bzip2
    openssl
    udev
    ncurses5
    tlf
    fontconfig
    pcsclite
    python3

    stlink-server
    ncurses5
  ];

  runScript = ''
    ${stm32cubeide}/stm32cubeide
  '';
}
