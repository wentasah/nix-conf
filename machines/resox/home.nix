{ config, pkgs, ... }:

let
  lib = pkgs.lib;
  texlive = pkgs.texlive.override { python3 = (pkgs.python3.withPackages (ps: [ ps.pygments ])); };
  mytexlive = texlive.combine {
    inherit (pkgs.texlive) scheme-full;
    pkgFilter =
      pkg:
      pkg.tlType == "run"
      || pkg.tlType == "bin"
      || (
        pkg.tlType == "doc"
        &&
          # Prevent collisions
          !builtins.elem pkg.pname [ "core" ]
      );
  };
  #carla = pkgs.callPackage ../../pkgs/carla { };
  julia = pkgs.julia-stable-bin; # import ../../pkgs/julia-bin.nix { inherit pkgs; };
  pod-mode = import ../../pkgs/pod-mode.nix { inherit pkgs; };
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

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
  programs.home-manager.path = "$HOME/nix/home-manager";

  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "wsh";
  home.homeDirectory = "/home/wsh";

  #home.extraOutputsToInstall = [ "devman" "devdoc" ];

  home.packages =
    with pkgs;
    let
      setPrio = lib.setPrio;
      # Prevent collision of addr2lines between binutils and clang
      binutils-unwrapped-all-targets = setPrio 0 pkgs.binutils-unwrapped-all-targets;
      clang = setPrio 1 pkgs.clang;
      gcc = setPrio 2 pkgs.gcc; # Prio over clang's c++ etc.
    in
    [
      adoptopenjdk-icedtea-web
      afew
      atool
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
      cppreference-doc
      #cura broken
      cutter
      devhelp
      difftastic
      dnsmasq # for documentation
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
      gcc
      glibcInfo # Not visible in emacs :-(
      gnome-tweaks
      gxplugins-lv2
      hdf5
      (lib.hiPrio (btop.override { rocmSupport = true; })) # hiPrio = override home-base.nix
      hugo
      (ikiwiki.override { docutilsSupport = true; gitSupport = true; })
      jack2
      julia-wrapper
      lazydocker
      libev # to have the man page ready
      libnotify # for notify-send (for mailsync)
      libreoffice-fresh
      libsecret
      licenseutils
      linuxPackages.perf
      lsof # TODO: git-annex assistant should depend on this
      man-pages
      mytexlive
      nasm
      nix-index
      nodePackages.markdownlint-cli
      nodePackages.typescript-language-server
      notify-while-running
      notmuch
      notmuch.emacs
      novaboot # from novaboot overlay
      openssl
      perl.devdoc
      perlPackages.AppClusterSSH
      perlPackages.Expect.devdoc # manpage for novaboot development
      (pkgs.callPackage ../../pkgs/cargo-prefetch { })
      #(pkgs.callPackage ../../pkgs/diffsitter {})
      playerctl
      pod-mode
      pulseaudio # I use pactl in ~/.i3/config (even with pipewire)
      python3Packages.jupyter_core
      python3Packages.notebook
      python3Packages.python-lsp-server
      qemu
      qjackctl
      radare2
      saleae-logic-2
      #slack
      sterm
      #stm32cubeide
      tcpreplay
      #teams
      unfs3
      unrar
      usbrelay
      usbutils
      v4l-utils # for qv4l2
      wireshark
      x11docker
      x42-plugins
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
      #zulip # depends on insecure electron_32 (2024-03-09)
      #zulip-term #broken

      # Emacs versions from emacs-overlay
      #     (pkgs.writeShellScriptBin "emacs-unstable" ''exec ${emacs-unstable}/bin/emacs "$@"'')
      #     (pkgs.writeShellScriptBin "emacs-pgtk-gcc" ''exec ${emacsPgtkNativeComp}/bin/emacs "$@"'')

      # Unfree fonts
      xkcd-font
    ]
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
    "bin/ssh-askpass" = {
      executable = true;
      text = ''
        #!${pkgs.runtimeShell}
        exec ${pkgs.x11_ssh_askpass}/libexec/x11-ssh-askpass
      '';
    };
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
