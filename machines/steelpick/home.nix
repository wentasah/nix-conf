{ config, pkgs, ... }:

let
  lib = pkgs.lib;
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
    ../../modules/home-base.nix
    ../../modules/home-desktop.nix
    ../../modules/sway.nix
    ../../modules/hyprland.nix
    ../../modules/gdu.nix
    ../../modules/go.nix
    ../../modules/git-annex.nix
    ../../modules/linux-build.nix
    ../../modules/mail.nix
    ../../modules/nautilus-open-any-terminal.nix
    ../../modules/fonts.nix
    ../../modules/qtcreator.nix
    ../../modules/msmtp.nix
  ];

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
    #ardour jack2 x42-plugins gxplugins-lv2 qjackctl # broken 2025-01-23
    atool
    auto-multiple-choice
    automake
    #avidemux # broken 2025-01-23
    bear
    binutils-unwrapped-all-targets
    bison
    bubblewrap
    can-utils
    cask
    clang
    clang-tools
    clementine
    clinfo
    cmakeWithGui
    cppreference
    #cura # currently broken (related: https://github.com/NixOS/nixpkgs/issues/186570)
    cutter
    devhelp
    difftastic
    distrobox
    dnsmasq                     # for documentation
    docker-compose
    dpkg
    dunst
    easyeffects
    #emacs-all-the-icons-fonts
    exif
    fdupes
    (feedgnuplot.override { gnuplot = gnuplot_qt; })
    #firejail
    flex
    flowblade
    foxglove-studio
    gcc
    ghostscript
    glibcInfo                   # Not visible in emacs :-(
    gnome-tweaks
    #gnome3.nautilus
    hdf5
    (hiPrio nixfmt-rfc-style)   # override nixfmt
    hugo
    (ikiwiki.override { docutilsSupport = true; gitSupport = true; })
   julia-wrapper
    #jupyter
    # korganizer akonadi
    lazydocker
    lexicon
    libev # to have the man page ready
    libnotify # for notify-send (for mailsync)
    libsecret
    licenseutils
    linuxPackages.perf
    lsof # TODO: git-annex assistant should depend on this
    man-pages
    mytexlive
    nasm
    nodePackages.markdownlint-cli
    nodePackages.typescript-language-server
    notify-while-running
    notmuch
    notmuch.emacs
    novaboot                    # from novaboot overlay
    openssl
    perl.devdoc
    perlPackages.Expect.devdoc         # manpage for novaboot development
    pidgin
    (pkgs.callPackage ../../pkgs/cargo-prefetch {})
    #(pkgs.callPackage ../../pkgs/diffsitter {})
    (pkgs.callPackage ../../pkgs/enumerate-markdown {})
    playerctl
    pod-mode
    python3Packages.jupyter_core
    python3Packages.notebook
    qemu
    radare2
    saleae-logic-2
    #slack
    ssh-to-age
    steam-run
    sterm
    stm32cubeide
    tcpreplay
    texpresso
    unrar
    usbrelay
    usbutils
    v4l-utils # for qv4l2
    vivado # from nix-xilinx overlay
    warp
    wireshark
    wol
    wrenv
    wrwb
    x11docker
    xf86_input_wacom
    xorg.xev
    xorg.xhost # for quick way to run GUI apps in chroots/containers
    xorg.xkbcomp
    xorg.xkill
    xorg.xorgdocs
    xplr
    xpra
    xrectsel
    zotero
    # zulip # depends on insecure electron_32 (2024-03-09)
    zulip-term

    # Emacs versions from emacs-overlay
    #(pkgs.writeShellScriptBin "emacs-unstable" ''exec ${emacs-unstable}/bin/emacs "$@"'')
    #(pkgs.writeShellScriptBin "emacs-git" ''exec ${emacsGit}/bin/emacs "$@"'')

    # Unfree fonts
    xkcd-font
  ]
  ++ (with pkgsCross.aarch64-multiplatform; [
    buildPackages.gcc
    (lib.setPrio 20 buildPackages.bintools-unwrapped) # aarch64-unknown-linux-gnu-objdump etc.
  ])
  ++ (with pkgsCross.armhf-embedded; [
    buildPackages.gcc
    (lib.setPrio 21 buildPackages.bintools-unwrapped) # arm-none-eabihf-objdump etc.
  ])
  ++ (with pkgsCross.armv7l-hf-multiplatform; [
    buildPackages.gcc
    (lib.setPrio 22 buildPackages.bintools-unwrapped) # armv7l-unknown-linux-gnueabihf-objdump etc.
  ])
  ++ (with pkgsCross.mingwW64; [
    buildPackages.gcc
    #(lib.setPrio 20 buildPackages.bintools-unwrapped) # aarch64-unknown-linux-gnu-objdump etc.
  ])
#   ++ (with pkgsCross.raspberryPi; [
#     buildPackages.gcc
#     (lib.setPrio 20 buildPackages.bintools-unwrapped)
#   ])
  ;

  home.file = {
    "bin/ssh-askpass" = { executable = true; text = ''
      #!${pkgs.runtimeShell}
      exec ${pkgs.x11_ssh_askpass}/libexec/x11-ssh-askpass
    ''; };
  };

  home.sessionVariables = {
    NIX_PATH = "nixpkgs=$HOME/nix/nixpkgs:$NIX_PATH";
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

  programs.chromium = {
    enable = true;
    commandLineArgs = [
      "--ozone-platform-hint=auto"
      "--enable-features=TouchpadOverscrollHistoryNavigation"
    ];
  };

  services.gpg-agent.enable = true;
  services.gpg-agent.enableExtraSocket = true;
  services.gpg-agent.pinentryPackage = pkgs.pinentry-gnome3;

  #services.lorri.enable = true;

  systemd.user.services = {

    # Run way-displays on steelpick, but not on my other computers.
    way-displays = {
      Unit = {
        Description = "way-displays: Auto Manage Your Wayland Displays";
        After = [ "graphical-session-pre.target" ];
        PartOf = [ "graphical-session.target" ];
      };
      Install.WantedBy = [ "sway-session.target" ];
      Service = {
        ExecStartPre = "${pkgs.coreutils}/bin/rm -f /tmp/way-displays.pid"; # Remove potentially stale .pid file
        ExecStart = "${pkgs.way-displays}/bin/way-displays";
      };
    };

    backup-etc-git = {
      Unit = {
        Description = "Backup etc git from servers";
      };
      Service = {
        ExecStart = "${pkgs.git}/bin/git --git-dir=%h/srv/etc fetch --all";
        Environment = "SSH_ASKPASS= SSH_AUTH_SOCK=/run/user/%U/ssh-agent";
      };
    };

    backup-overleaf = {
      Unit = {
        Description = "Backup overleaf repos";
      };
      Service = {
        ExecCondition = "${pkgs.bash}/bin/bash -c '! nmcli --get-values GENERAL.METERED dev show|grep -F yes'";
        ExecStart = "%h/bin/fetch-all-overleaf";
        WorkingDirectory = "%h/papers/_in-progress";
        Environment = "SSH_ASKPASS= SSH_AUTH_SOCK=/run/user/%U/ssh-agent";
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
