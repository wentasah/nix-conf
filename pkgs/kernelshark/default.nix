{ pkgs ? import <nixpkgs> {} }:
with pkgs;
#{ lib, stdenv, fetchgit, asciidoc, docbook_xsl, libxslt }:
let
  libtraceevent = stdenv.mkDerivation rec {
    pname = "libtraceevent";
    version = "1.1.2";

    src = fetchgit {
      url = "git://git.kernel.org/pub/scm/libs/libtrace/libtraceevent.git/";
      rev = "libtraceevent-${version}";
      sha256 = "0pdf68ph491j1qi6h9b8pbddbww80afddxfrrv2757z5whjby432";
    };

    outputs = [ "out" "dev" ];
    enableParallelBuilding = true;
    nativeBuildInputs = [ pkg-config ];
    makeFlagsArray = [
      "prefix=${placeholder "out"}"
    ];
    installFlags = [
      "pkgconfig_dir=${placeholder "out"}/lib/pkgconfig"
    ];
  };
  libtracefs = stdenv.mkDerivation rec {
    pname = "libtracefs";
    version = "1.0.2";

    src = fetchgit {
      url = "git://git.kernel.org/pub/scm/libs/libtrace/libtracefs.git/";
      rev = "libtracefs-${version}";
      sha256 = "12928x74la8fnpp1776x041rawjb8znpjwm8w49a56k1krxzilg1";
    };

    outputs = [ "out" "dev" ];
    enableParallelBuilding = true;
    nativeBuildInputs = [ pkg-config ];
    buildInputs = [ libtraceevent ];
    makeFlagsArray = [
      "prefix=${placeholder "out"}"
    ];
    installFlags = [
      "pkgconfig_dir=${placeholder "out"}/lib/pkgconfig"
    ];
  };
  trace-cmd = stdenv.mkDerivation {
    pname = "trace-cmd";
    version = "2.9.1-130-g2191498";           # 2.9.1 + two "fix" commits

    src = fetchgit {
      #url = /home/wsh/src/trace-cmd;
      url = "git://git.kernel.org/pub/scm/utils/trace-cmd/trace-cmd.git";
      rev = "379e5f0b311f29adc01330701b76d6b6c093e9e6";
      sha256 = "1jvl1lmii9wcigvh6awx31x8bfzm6m2hw57zyxr4wvg2aybr1li8";
    };

    #patches = [ ./fix-Makefiles.patch ];

    nativeBuildInputs = [ asciidoc libxslt docbook_xsl pkg-config breakpointHook ];

    buildInputs = [ libtraceevent ];

    outputs = [ "out" "lib" "dev" "man" ];

    MANPAGE_DOCBOOK_XSL="${docbook_xsl}/xml/xsl/docbook/manpages/docbook.xsl";

    enableParallelBuilding = true;

    dontConfigure = true;

    buildPhase = "make trace-cmd libs doc";

    installTargets = [ "install_cmd" "install_libs" "install_doc" ];
    installFlags = [
      "-j8"
      "bindir=${placeholder "out"}/bin"
      "man_dir=${placeholder "man"}/share/man"
      "libdir=${placeholder "lib"}/lib"
      "pkgconfig_dir=${placeholder "lib"}/lib/pkgconfig"
      "includedir=${placeholder "dev"}/include"
      "BASH_COMPLETE_DIR=${placeholder "out"}/share/bash-completion/completions"

      # Don't mess up with ldconfig. From Makefile:
      #     If DESTDIR is not defined, then test if after installing the library
      #     and running ldconfig, if the library is visible by ld.so.
      #     If not, add the path to /etc/ld.so.conf.d/trace.conf and run ldconfig again.
      "DESTDIR=/"
      "MAN3_INSTALL=" # man3 installation is currently broken
    ];

    meta = with lib; {
      description = "User-space tools for the Linux kernel ftrace subsystem";
      homepage    = "https://kernelshark.org/";
      license     = licenses.gpl2;
      platforms   = platforms.linux;
      maintainers = with maintainers; [ thoughtpolice basvandijk ];
    };
  };
in
stdenv.mkDerivation rec {
  pname = "kernelshark";
  version = "1.2-124-g2191498";

#   src = fetchgit {
#     url = "https://git.kernel.org/pub/scm/utils/trace-cmd/kernel-shark.git/";
#     rev = "f05e3e75bd95cb7e0e5849899d70fd6aeb24f5cc";
#     sha256 = "1247prbacdyiwcy0g97h4490fiqam3iwyfkmdi73r09ly78r98mj";
#   };
  src = fetchGit {
    url = /home/wsh/src/kernel-shark;
  };

  #patches = [ ./cmake.patch ];

  #outputs = [ "out" "doc" ];

  nativeBuildInputs = [ pkg-config cmake asciidoc ];

  buildInputs = [ libsForQt5.qtbase libsForQt5.wrapQtAppsHook json_c mesa_glu freeglut
                  libtraceevent libtracefs trace-cmd
                ];

  cmakeFlags = [
    "-D_INSTALL_PREFIX=${placeholder "out"}"
    "-D_POLKIT_INSTALL_PREFIX=${placeholder "out"}"
    "-DPKG_CONGIG_DIR=${placeholder "out"}/lib/pkgconfig"
    "-DTT_FONT_FILE=${freefont_ttf}/share/fonts/truetype/FreeSans.ttf"
  ];

  meta = with lib; {
    description = "GUI for trace-cmd which is an interface for the Linux kernel ftrace subsystem";
    homepage    = "https://kernelshark.org/";
    license     = licenses.gpl2;
    platforms   = platforms.linux;
    maintainers = with maintainers; [ basvandijk ];
  };
}
