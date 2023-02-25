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
  carla = pkgs.callPackage ../../pkgs/carla { };
  julia = pkgs.julia-stable-bin; # import ../../pkgs/julia-bin.nix { pkgs = pkgs; };
  lexicon = import ../../pkgs/lexicon.nix { pkgs = pkgs; };
  cppreference = import ../../pkgs/cppreference.nix { pkgs = pkgs; };
  pod-mode = import ../../pkgs/pod-mode.nix { pkgs = pkgs; };
  stm32cubeide = import ../../pkgs/stm32cubeide { pkgs = pkgs; };
  licenseutils = import ../../pkgs/licenseutils { pkgs = pkgs; };
  #kernelshark = import ../../pkgs/kernelshark { pkgs = pkgs; };
  julia-wrapper = pkgs.callPackage ../../pkgs/julia-wrapper { inherit julia; };
  globalPythonPackages = (pp: with pp; [
    requests urllib3 # for filesender.py
    matplotlib
  ]);
in
{
  imports = [
    ../../modules/home-base.nix
    ../../modules/i3.nix
    ../../modules/gdu.nix
    ../../modules/go.nix
    ../../modules/git-annex.nix
    ../../modules/linux-build.nix
    ../../modules/fonts.nix
    ../../modules/qtcreator.nix
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

  home.packages = with pkgs; [

    # pdfpc                       # using my custom modified version
    #(pkgs.callPackage ../../pkgs/diffsitter {})
    #emacs-all-the-icons-fonts
    #firejail
    #gnome3.nautilus
    #gtkterm
    #jupyter
    #slack
    #teams
    (feedgnuplot.override { gnuplot = gnuplot_qt; })
    (gnuplot_qt.override { withCaca = true; })
    (hiPrio gcc) # Prio over clang's c++ etc
    (ikiwiki.override { docutilsSupport = true; })
    (python3.withPackages globalPythonPackages)
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
    cask
    chromium
    clang
    clang-tools
    clementine
    clinfo
    cmakeWithGui
    cura
    #cutter # currently broken
    difftastic
    dpkg
    drawio
    dunst
    easyeffects
    exif
    fdupes
    flameshot
    flex
    flowblade
    #freecad # broken
    gimp
#    glib.out                    # for gdbus bash completion
    glibcInfo                   # Not visible in emacs :-(
    gnome3.devhelp
    gnome.gnome-tweaks
    gtkterm
    hdf5
    hotspot
    hugo
    inkscape
    isync
    julia-wrapper
    kdiff3
    keepassxc
    kernelshark
    kicad-small
    krita
    lazydocker
    libev # to have the man page ready
    libnotify # for notify-send (for mailsync)
    libreoffice-fresh
    libsecret
    linuxPackages.perf
    lsof # TODO: git-annex assistant should depend on this
    man-pages
    meld
    musescore
    mytexlive
    nasm
    nix-index
    #nodePackages.markdownlint-cli
    nodePackages.typescript-language-server
    notify-while-running
    notmuch
    notmuch.emacs
    okteta
    okular
    openssl
    pavucontrol
    pdfpc
    perl.devdoc
    perlPackages.AppClusterSSH
    perlPackages.Expect.devdoc         # manpage for novaboot development
    pidgin
    playerctl
    pulseaudio                  # I use pactl in ~/.i3/config (even with pipewire)
    python3Packages.jupyter_core
    # python3Packages.notebook # broken because python3.10-mistune-0.8.4 is insecure (since https://github.com/NixOS/nixpkgs/pull/184209)
    python3Packages.python-lsp-server
    qemu
    radare2
    screenkey
    shotcut
    smplayer mpv mplayer
    solvespace
    sqlitebrowser
    sterm
    tcpreplay
    thunderbird
    usbrelay
    usbutils
    v4l-utils # for qv4l2
    vlc
    wireshark
    wmctrl
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
    xournal
    xournalpp
    xplr
    xpra
    xrectsel
    zotero
    zulip
    #zulip-term #broken
  ];



  home.file = {
    "bin/ssh-askpass" = { executable = true; text = ''
      #!${pkgs.runtimeShell}
      exec ${pkgs.x11_ssh_askpass}/libexec/x11-ssh-askpass
    ''; };
  };

  home.sessionVariables = {
    JULIA_EDITOR = "emacsclient";
    GIT_PAGER = "less -FRX";    # overrides PAGER set by oh-my-zsh
    NIX_PATH = "nixpkgs=$HOME/nix/nixpkgs:$NIX_PATH";
  };

  programs.man.enable = true;
  programs.man.generateCaches = true;
  programs.info.enable = true;

  programs.obs-studio.enable = true;
  programs.obs-studio.plugins = with pkgs; [
    #obs-v4l2sink # built into OBS since 26.1
    #(callPackage ./obs-shaderfilter-plus.nix {})
    #(callPackage ~/src/obs/obs-shaderfilter/obs-shaderfilter.nix {})
  ];

  services.xsettingsd.enable = true;
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
