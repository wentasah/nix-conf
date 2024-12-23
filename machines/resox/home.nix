{ config, pkgs, ... }:

let
  lib = pkgs.lib;
  firejailedBinaries = {        # TODO: create wrapper automatically
#     slack = "${pkgs.slack}/bin/slack";
#     teams = "${pkgs.teams}/bin/teams";
#     skypeforlinux = "${pkgs.skypeforlinux}/bin/skypeforlinux";
  };
  texlive = pkgs.texlive.override { python3 = (pkgs.python3.withPackages (ps: [ ps.pygments ])); };
  mytexlive = texlive.combine {
    inherit (pkgs.texlive) scheme-full;
    pkgFilter = (pkg:
      pkg.tlType == "run"
      || pkg.tlType == "bin"
      || (
        pkg.tlType == "doc" &&
        # Prevent collisions
        !builtins.elem pkg.pname [ "core" ]
      ));
  };
  #carla = pkgs.callPackage ../../pkgs/carla { };
  julia = pkgs.julia-stable-bin; # import ../../pkgs/julia-bin.nix { inherit pkgs; };
  lexicon = import ../../pkgs/lexicon.nix { inherit pkgs; };
  wrwb = import ../../pkgs/wrwb.nix { inherit pkgs; };
  wrenv = import ../../pkgs/wrenv.nix { inherit pkgs; };
  cppreference = import ../../pkgs/cppreference.nix { inherit pkgs; };
  pod-mode = import ../../pkgs/pod-mode.nix { inherit pkgs; };
  stm32cubeide = import ../../pkgs/stm32cubeide { inherit pkgs; };
  licenseutils = import ../../pkgs/licenseutils { inherit pkgs; };
  #kernelshark = import ../../pkgs/kernelshark { inherit pkgs; };
  julia-wrapper = pkgs.callPackage ../../pkgs/julia-wrapper { inherit julia; };
in
{
  imports = [
    ../../modules/fonts.nix
    ../../modules/gdu.nix
    ../../modules/git-annex.nix
    ../../modules/go.nix
    ../../modules/home-base.nix
    ../../modules/home-desktop.nix
    ../../modules/linux-build.nix
    ../../modules/msmtp.nix
    ../../modules/nautilus-open-any-terminal.nix
    ../../modules/qtcreator.nix
    ../../modules/sway.nix
    ../../modules/xdp-no-gnome.nix
  ];

  nixpkgs = {
    config = {
      allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
        "unrar"
#         "skypeforlinux"
#         "slack"
#         "teams"
      ];
      allowBroken = false;
      allowUnsupportedSystem = false;
    };
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
  programs.home-manager.path = "$HOME/nix/home-manager";

  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "wsh";
  home.homeDirectory = "/home/wsh";

  #home.extraOutputsToInstall = [ "devman" "devdoc" ];

  home.packages = with pkgs; let
    setPrio = lib.setPrio;
    # Prevent collision of addr2lines between binutils and clang
    binutils-unwrapped-all-targets = setPrio 0 pkgs.binutils-unwrapped-all-targets;
    clang = setPrio 1 pkgs.clang;
    gcc = setPrio 2 pkgs.gcc; # Prio over clang's c++ etc.
  in [
    adoptopenjdk-icedtea-web
    afew
    arandr
    ardour jack2 x42-plugins gxplugins-lv2 qjackctl
    atool
    audacity
    auto-multiple-choice
    automake
    avidemux
    bear
    binutils-unwrapped-all-targets
    bison
    bubblewrap
    can-utils
    carla-bin
    cask
    chromium
    clang
    clang-tools
    clementine
    clinfo
    cmakeWithGui
    cppreference
    #cura broken
    cutter
    difftastic
    dnsmasq                     # for documentation
    docker-compose
    dpkg
    drawio
    dunst
    easyeffects
    #emacs-all-the-icons-fonts
    exif
    fdupes
    (feedgnuplot.override { gnuplot = gnuplot_qt; })
    firefox
    #firejail
    #flameshot # crashes under sway!
    flex
    flowblade
    freecad
    gcc
    gimp
    glibcInfo                   # Not visible in emacs :-(
    devhelp
    gnome-tweaks
    (gnuplot_qt.override { withCaca = true; })
    gtkterm
    hdf5
    (hiPrio (btop.override { rocmSupport = true; })) # hiPrio = override home-base.nix
    hotspot
    hugo
    (ikiwiki.override { docutilsSupport = true; gitSupport = true; })
    inkscape
    julia-wrapper
    kdiff3
    keepassxc
    kernelshark
    kicad-small
    kitty
    krita
    lazydocker
    libev # to have the man page ready
    libnotify # for notify-send (for mailsync)
    libreoffice-fresh
    libsecret
    licenseutils
    linuxPackages.perf
    lsof # TODO: git-annex assistant should depend on this
    man-pages
    meld
    musescore
    mytexlive
    nasm
    nix-index
    nodePackages.markdownlint-cli
    nodePackages.typescript-language-server
    notify-while-running
    notmuch
    notmuch.emacs
    novaboot                    # from novaboot overlay
    okteta
    okular
    openssl
    pavucontrol
    pdfpc
    perl.devdoc
    perlPackages.AppClusterSSH
    perlPackages.Expect.devdoc         # manpage for novaboot development
    pidgin
    (pkgs.callPackage ../../pkgs/cargo-prefetch {})
    #(pkgs.callPackage ../../pkgs/diffsitter {})
    (pkgs.callPackage ../../pkgs/enumerate-markdown {})
    playerctl
    pod-mode
    pulseaudio                  # I use pactl in ~/.i3/config (even with pipewire)
    python3Packages.jupyter_core
    python3Packages.notebook
    python3Packages.python-lsp-server
    qemu
    radare2
    saleae-logic-2
    screenkey
    shotcut
    #slack
    smplayer mpv mplayer
    solvespace
    sqlitebrowser
    sterm
    #stm32cubeide
    tcpreplay
    #teams
    thunderbird
    unfs3
    unrar
    usbrelay
    usbutils
    v4l-utils # for qv4l2
    video-trimmer
    vlc
    wireshark
    wmctrl
    # (writeShellScriptBin "flameshot" ''QT_QPA_PLATFORMTHEME=gtk2 ${flameshot}/bin/flameshot "$@"'')
    x11docker
    xclip
    xdotool
    xdragon
    xf86_input_wacom
    xorg.xev
    xorg.xhost # for quick way to run GUI apps in chroots/containers
    xorg.xkbcomp
    xorg.xkill
    xorg.xorgdocs
    xournalpp
    xplr
    xpra
    xrectsel
    zotero
    zulip
    #zulip-term #broken

    # Emacs versions from emacs-overlay
#     (pkgs.writeShellScriptBin "emacs-unstable" ''exec ${emacs-unstable}/bin/emacs "$@"'')
#     (pkgs.writeShellScriptBin "emacs-pgtk-gcc" ''exec ${emacsPgtkNativeComp}/bin/emacs "$@"'')

    # Unfree fonts
    xkcd-font
  ]
  ++ lib.attrVals (builtins.attrNames firejailedBinaries) pkgs
  ++ (with pkgsCross.aarch64-multiplatform; [
    buildPackages.gcc
    (setPrio 20 buildPackages.bintools-unwrapped) # aarch64-unknown-linux-gnu-objdump etc.
  ])
#   ++ (with pkgsCross.armhf-embedded; [
#     buildPackages.gcc
#     (setPrio 21 buildPackages.bintools-unwrapped) # arm-none-eabihf-objdump etc.
#   ])
  ++ (with pkgsCross.armv7l-hf-multiplatform; [
    buildPackages.gcc
    (setPrio 22 buildPackages.bintools-unwrapped) # armv7l-unknown-linux-gnueabihf-objdump etc.
  ])
  ++ (with pkgsCross.mingwW64; [
    buildPackages.gcc
    #(setPrio 20 buildPackages.bintools-unwrapped) # aarch64-unknown-linux-gnu-objdump etc.
  ])
#   ++ (with pkgsCross.raspberryPi; [
#     buildPackages.gcc
#     (setPrio 20 buildPackages.bintools-unwrapped)
#   ])
  ;



  home.file = {
    "bin/ssh-askpass" = { executable = true; text = ''
      #!${pkgs.runtimeShell}
      exec ${pkgs.x11_ssh_askpass}/libexec/x11-ssh-askpass
    ''; };
  };

  home.sessionVariables = {
    NIX_PATH = "nixpkgs=$HOME/nix/nixpkgs-stable:$NIX_PATH";
  };

  programs.man.enable = true;
  #programs.man.generateCaches = true;
  programs.info.enable = true;

  programs.obs-studio.enable = true;
  programs.obs-studio.plugins = with pkgs; [
    #obs-v4l2sink # built into OBS since 26.1
    #(callPackage ./obs-shaderfilter-plus.nix {})
    #(callPackage ~/src/obs/obs-shaderfilter/obs-shaderfilter.nix {})
  ];

  services.gpg-agent.enable = true;
  services.gpg-agent.enableExtraSocket = true;

  #services.lorri.enable = true;

  systemd.user.services = {

    backup-etc-git = {
      Unit = {
        Description = "Backup etc git from servers";
      };
      Service = {
        ExecStart = "${pkgs.git}/bin/git --git-dir=%h/srv/etc fetch --all";
        Environment = "SSH_ASKPASS=";
      };
    };

    backup-overleaf = {
      Unit = {
        Description = "Backup overleaf";
      };
      Service = {
        ExecStart = "${pkgs.git}/bin/git --git-dir=%h/thermac/D5.3-overleaf fetch --all";
        Environment = "SSH_ASKPASS=";
      };
    };

    notmuch-dump-tags = {
      Service = {
        ExecStart = "${pkgs.gnumake}/bin/make -C %h/repos/notmuch-tags";
      };
    };
  };

#   xdg.mimeApps = {
#     enable = true;
#   };

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "20.09";
}

# Local Variables:
# compile-command: "home-manager switch"
# End:
