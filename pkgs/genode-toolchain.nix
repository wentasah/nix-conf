{
  stdenv,
  lib,
  fetchurl,
  autoPatchelfHook,
  patchelf,
  expat,
  flex,
  gmp,
  ncurses,
  python312,
  zlib,
  zstd,
  libGL,
  libxkbcommon,
  fontconfig,
  freetype,
  glib,
  dbus,
  icu74,
}:

let
  # patchelf 0.19.2 corrupts some of the toolchain binaries (e.g. cc1
  # segfaults immediately). 0.19.3 fixes that.
  patchelf_0_19_3 =
    if lib.versionOlder patchelf.version "0.19.3" then
      patchelf.overrideAttrs (old: rec {
        version = "0.19.3";
        src = fetchurl {
          url = "https://github.com/NixOS/patchelf/releases/download/${version}/patchelf-${version}.tar.bz2";
          hash = "sha256-INviPp28StdpB4qGetACwEKXoGn/k8lftyJC3VXU3W8=";
        };
      })
    else
      patchelf;
in
stdenv.mkDerivation rec {
  pname = "genode-toolchain";
  version = "25.05";

  src = fetchurl {
    url = "https://codeberg.org/genodelabs/genode/releases/download/${version}/genode-toolchain-${version}-ubuntu-24.04.tar.xz";
    hash = "sha256-bKuOX0SQOZopanOwFpXV+wVaQPasBNYaP3pzRAA+tzk=";
  };

  sourceRoot = ".";

  nativeBuildInputs = [
    patchelf_0_19_3 # must precede the default patchelf in PATH
    autoPatchelfHook
  ];

  buildInputs = [
    expat
    flex # libfl.so.2
    gmp
    ncurses
    python312
    stdenv.cc.cc.lib # libstdc++, libgcc_s
    zlib
    zstd
    # Bundled Qt (used by Genode's Qt tooling)
    libGL
    libxkbcommon
    fontconfig
    freetype
    glib
    dbus
    icu74
  ];

  # Bundled Qt plugins may reference libraries we don't care about.
  autoPatchelfIgnoreMissingDeps = true;

  # Do not strip/patch cross-compiled target libraries.
  dontStrip = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/opt/genode-toolchain $out/bin
    cp -a usr/local/genode/tool/${version}/. $out/opt/genode-toolchain/
    # Dangling symlink shipped in the tarball
    find $out/opt/genode-toolchain -xtype l -delete
    # Expose only the genode-* tools in PATH (bin/ also contains Qt tools
    # like moc that would clash with other packages). Genode's build system
    # can use them by setting e.g. CROSS_DEV_PREFIX = genode-x86- in
    # build.conf, or point it at $out/opt/genode-toolchain.
    for f in $out/opt/genode-toolchain/bin/genode-*; do
      ln -s "$f" $out/bin/
    done

    runHook postInstall
  '';

  # Make the libraries bundled in the tarball resolvable by autoPatchelf.
  preFixup = ''
    addAutoPatchelfSearchPath $out/opt/genode-toolchain/lib
    addAutoPatchelfSearchPath $out/opt/genode-toolchain/lib64
    addAutoPatchelfSearchPath $out/opt/genode-toolchain/qt6/lib
  '';

  meta = {
    description = "Pre-built Genode tool chain (GCC/binutils/GDB for x86, ARM, AArch64, RISC-V)";
    homepage = "https://genode.org/download/tool-chain";
    license = lib.licenses.gpl3Plus;
    platforms = [ "x86_64-linux" ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
}
