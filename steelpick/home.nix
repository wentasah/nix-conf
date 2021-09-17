{ config, pkgs, ... }:

let
  lib = pkgs.lib;
  firejailedBinaries = {        # TODO: create wrapper automatically
#     slack = "${pkgs.slack}/bin/slack";
#     teams = "${pkgs.teams}/bin/teams";
#     skypeforlinux = "${pkgs.skypeforlinux}/bin/skypeforlinux";
  };
  mytexlive = pkgs.texlive.combine {
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
  julia = import ../pkgs/julia-bin.nix { pkgs = pkgs; };
  lexicon = import ../pkgs/lexicon.nix { pkgs = pkgs; };
  cppreference = import ../pkgs/cppreference.nix { pkgs = pkgs; };
  pod-mode = import ../pkgs/pod-mode.nix { pkgs = pkgs; };
  gtkterm = import ../pkgs/gtkterm.nix { pkgs = pkgs; };
  stm32cubeide = import ../pkgs/stm32cubeide { pkgs = pkgs; };
  licenseutils = import ../pkgs/licenseutils { pkgs = pkgs; };
  #kernelshark = import ../pkgs/kernelshark { pkgs = pkgs; };
in
{
  imports = [
    ../modules/i3.nix
    ../modules/gdu.nix
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

  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "wsh";
  home.homeDirectory = "/home/wsh";

  #home.extraOutputsToInstall = [ "devman" "devdoc" ];

  home.packages = with pkgs; [

    # pdfpc                       # using my custom modified version
    #(pkgs.callPackage ../pkgs/diffsitter {})
    #(qtcreator.override { withClangPlugins = false; }) # too old in nixpkgs - patched in my local copy
    #firejail
    #gnome3.nautilus
    #gtkterm
    #jupyter
    #python3Packages.python-language-server # broken with python 3.9
    #slack
    #teams
    (binutils-unwrapped.override { withAllTargets = true; enableShared = false; }) # https://github.com/NixOS/nixpkgs/issues/82792
    (gnuplot_qt.override { withCaca = true; })
    (hiPrio gcc) # Prio over clang's c++ etc
    (hiPrio parallel) # Prefer this over parallel from moreutils
    (import ../pkgs/unfs3 { pkgs = pkgs; })
    (pkgs.callPackage ../pkgs/difftastic {})
    (pkgs.callPackage ../pkgs/enumerate-markdown {})
    adoptopenjdk-icedtea-web
    afew
    arandr
    ardour jack2 x42-plugins gxplugins-lv2 qjackctl
    aspell
    aspellDicts.cs
    aspellDicts.en
    aspellDicts.en-computers
    aspellDicts.en-science
    atool
    atop
    audacity
    automake
    avidemux
    bbe
    bc                          # For linux kernel compilation
    bison
    cachix
    can-utils
    cask
    ccls
    chromium
    clang
    clang-tools
    clementine
    clinfo
    cloc
    cmakeWithGui
    colordiff
    cppreference
    csv2latex
    csvtool
    cura
    dpkg
    dragon-drop
    dua
    dunst
    exif
    fd
    fdupes
    ffmpeg
    firefox
    flex
    freecad
    gdb
    gh
    gimp
    gitAndTools.delta
    gitAndTools.git-annex
    gitAndTools.git-subtrac
    gitAndTools.tig
    gitui
    glibcInfo                   # Not visible in emacs :-(
    global
    gnome3.devhelp
    gnome3.libsecret
    gnumake
    gnupg
    gopls
    gpg-tui
    gtkterm
    hdf5
    htop
    hugo
    imagemagick
    inkscape
    isync
    jq
    julia
    kdiff3
    keepassxc
    kernelshark
    kicad-small
    krita
    lexicon
    libnotify # for notify-send (for mailsync)
    libreoffice-fresh
    libxml2 # for xmllint
    licenseutils
    linuxPackages.perf
    lsof # TODO: git-annex assistant should depend on this
    ltrace
    manpages
    mc
    meson
    ministat
    moreutils
    mosh
    mtr
    musescore
    mytexlive
    nasm
    ncdu
    ncurses6.dev                # for Linux's make manuconfig
    ninja
    niv
    nix-doc
    nix-output-monitor
    nix-prefetch
    nix-prefetch-scripts
    nix-review
    nix-template
    nix-tree
    nixfmt
    nixos-shell
    nixpkgs-fmt
    nodePackages.typescript-language-server
    notmuch
    notmuch.emacs
    nvd
    odt2txt
    okteta
    okular
    openssl
    openssl.dev                 # For linux kernel compilation
    p7zip
    pandoc
    pavucontrol
    pdf2svg
    pdftk
    perlPackages.AppClusterSSH
    perlPackages.Expect.devdoc         # manpage for novaboot development
    pidgin
    pkg-config
    playerctl
    pod-mode
    poppler_utils
    posix_man_pages
    psmisc                      # killall, fuser, ...
    pv
    python3
    python3Packages.jupyter_core
    python3Packages.notebook
    qemu
    qt5.full            # To make qtcreator find the qt automatically
    qtcreator
    radare2 radare2-cutter
    ranger
    redo-apenwarr
    restic
    ripgrep
    rnix-lsp
    roboto-slab
    rsync
    shellcheck
    shotcut
    smplayer mpv mplayer
    socat
    solvespace
    sqlitebrowser
    sshuttle
    stm32cubeide
    thunderbird
    tmux
    trace-cmd
    unzip
    usbutils
    v4l-utils # for qv4l2
    valgrind
    vlc
    websocat
    wmctrl
    xclip
    xdotool
    xf86_input_wacom
    xlibs.xorgdocs
    xorg.xev
    xorg.xhost # for quick way to run GUI apps in chroots/containers
    xorg.xkbcomp
    xorg.xkill
    xournal
    xournalpp
    xplr
    xpra
    xrectsel
    yamllint
    zip
    zotero
    zsh-completions
    zsh-syntax-highlighting
    zulip zulip-term
    (feedgnuplot.override { gnuplot = gnuplot_qt; })

    rustup
    # rustc cargo rls clippy
    rust-analyzer cargo-edit

    swaylock
#     (swaylock.overrideAttrs(old: {
#       src = fetchFromGitHub {
#         owner = "swaywm";
#         repo = "swayidle";
#         rev = "068942751ba459ef3b9ba0ec8eddf9f6f212c4d7";
#         # date = 2020-11-06T11:38:15+01:00;
#         sha256 = "1ml2n1rp8simpd2y4ff1anx2vj89f3a6dhfz8m2hdan749vwnxvk";
#       };
#       buildInputs = old.buildInputs ++ [ systemd ];
#     }))

    # Fonts
    roboto
    source-sans-pro
    source-serif-pro
    lato
    open-sans
    libertine # For images consistency with ACM latex template

  ] ++ lib.attrVals (builtins.attrNames firejailedBinaries) pkgs
  ++ (with pkgsCross.aarch64-multiplatform; [
    buildPackages.gcc
    (lib.setPrio 20 buildPackages.bintools-unwrapped) # aarch64-unknown-linux-gnu-objdump etc.
  ]);



  home.file = {
    "bin/emacsclient-tty" = {
      executable = true;
      text = ''
        #!${pkgs.runtimeShell}
        exec ${config.programs.emacs.package}/bin/emacsclient -t "$@"
      '';
    };
    "bin/ssh-askpass" = { executable = true; text = ''
      #!${pkgs.runtimeShell}
      exec ${pkgs.x11_ssh_askpass}/libexec/x11-ssh-askpass
    ''; };
    "bin/whix" = {
      executable = true;
      text = ''
        #!${pkgs.runtimeShell}
        realpath $(command which "$1")
      '';
    };
    "bin/whixd" = {
      executable = true;
      text = ''
        #!${pkgs.runtimeShell}
        [[ $(whix "$1") =~ ^/nix/store/[^/]* ]] && echo "''${BASH_REMATCH[0]}"
      '';
    };
  };

  # I have a problem with zsh when EDITOR is "vim". Pressing "delete"
  # prints "~" instead of deleting a char. For details why see:
  #
  #     EDITOR=vi zsh -i -c 'bindkey -e; bindkey' > key.vi
  #     EDITOR=em zsh -i -c 'bindkey -e; bindkey' > key.em
  #     diff -u --color key.vi key.em
  # The result should be same, but it isn't.
  home.sessionVariables = {
    EDITOR = "emacsclient-tty";
    JULIA_EDITOR = "emacsclient";
    GIT_PAGER = "less -FRX";    # overrides PAGER set by oh-my-zsh
    NIX_PATH = "nixpkgs=$HOME/nix/nixpkgs:$NIX_PATH";
  };

  home.sessionPath = [
    "~/go/bin"
  ];

  programs.man.enable = true;
  programs.man.generateCaches = true;
  programs.info.enable = true;

  programs.zsh = {
    enable = true;
    enableVteIntegration = true;
    history.path = "$HOME/.history";
    history.share = false;
    defaultKeymap = "emacs";
    shellAliases = {
      ag    = "ag --color-line-number='0;33' --color-path='0;32'";
      cp    = "nocorrect cp"; # no spelling correction on cp
      grep  = "grep --color";
      gst   = "git status";
      h     = "history";
      j     = "julia --project";
      jc    = "journalctl";
      l     = "ls -lAh";
      la    = "ls -a";
      ll    = "ls -l";
      ln    = "nocorrect ln"; # no spelling correction on ln
      lnr   = "nocorrect ln -s --relative";
      ls    = "ls --color=auto";
      lsa   = "ls -ld .*"; # List only file beginning with "."
      lsd   = "ls -ld *(-/DN)"; # List only directories and symbolic links that point to directories
      mkdir = "nocorrect mkdir"; # no spelling correction on mkdir
      mv    = "nocorrect mv"; # no spelling correction on mv
      o     = "octave -f --no-gui";
      r     = "ranger_cd";
      sc    = "systemctl";
      scp   = "${pkgs.rsync}/bin/rsync -aP --inplace";
      scs   = "systemctl status";
      scu   = "systemctl --user";
      scus  = "scu status";
      sudo  = "nocorrect sudo";
      touch = "nocorrect touch";
      which = "nocorrect which";
    };
    oh-my-zsh.enable = true;
    oh-my-zsh.plugins = [ "systemd" ];
    initExtra = ''
      DIRSTACKSIZE=100

      setopt notify interactivecomments recexact longlistjobs
      setopt autoresume pushdsilent autopushd pushdminus

      d() {
        local dir
        dir=$(dirs -l -p | fzf +m) &&
        cd $dir
      }

      # Rebind fzf-cd to a sane key
      bindkey '\eC' fzf-cd-widget
      bindkey '\ec' capitalize-word

      source ${pkgs.mc}/libexec/mc/mc.sh
      # if [[ -f /usr/share/mc/bin/mc.sh ]]; then
      #     source /usr/share/mc/bin/mc.sh
      # else
      #     if [[ -f /usr/libexec/mc/mc-wrapper.sh ]]; then
      #         alias mc='. /usr/libexec/mc/mc-wrapper.sh'
      #     fi
      # fi

      # Where to look for autoloaded function definitions
      fpath=(~/.zfunc $fpath)

      # # Autoload all shell functions from all directories in $fpath (following
      # # symlinks) that have the executable bit on (the executable bit is not
      # # necessary, but gives you an easy way to stop the autoloading of a
      # # particular shell function). $fpath should not be empty for this to work.
      # for func in $^fpath/*(N-.x:t); autoload $func

      source ${pkgs.zsh-syntax-highlighting}/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
      ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets)

      # Source localhost specific settings
      source ~/.zshrc.local

      autoload -Uz chpwd_recent_dirs cdr add-zsh-hook
      add-zsh-hook chpwd chpwd_recent_dirs
      zstyle ':completion:*:*:cdr:*:*' menu selection

      # autoload bashcompinit
      # bashcompinit

      vterm_printf(){
          if [ -n "$TMUX" ]; then
              # Tell tmux to pass the escape sequences through
              # (Source: http://permalink.gmane.org/gmane.comp.terminal-emulators.tmux.user/1324)
              printf "\ePtmux;\e\e]%s\007\e\\" "$1"
          elif [ "''${TERM%%-*}" = "screen" ]; then
              # GNU screen (screen, screen-256color, screen-256color-bce)
              printf "\eP\e]%s\007\e\\" "$1"
          else
              printf "\e]%s\e\\" "$1"
          fi
      }

      # Finally include zsh snippets
      for zshrc_snipplet in ~/.zshrc.d/S[0-9][0-9]*[^~] ; do
        source $zshrc_snipplet
      done

      ZSH_BASH_COMPLETIONS_FALLBACK_PATH=${pkgs.bash-completion}/share/bash-completion
      #ZSH_BASH_COMPLETIONS_FALLBACK_WHITELIST=(openssl)

      ranger_cd() {
          temp_file="$(mktemp -t "ranger_cd.XXXXXXXXXX")"
          ranger --choosedir="$temp_file" -- "''${@:-$PWD}"
          if chosen_dir="$(cat -- "$temp_file")" && [ -n "$chosen_dir" ] && [ "$chosen_dir" != "$PWD" ]; then
              cd -- "$chosen_dir"
          fi
          rm -f -- "$temp_file"
      }

      # Hostnames in K23 lab
      k23="k23-177 k23-178 k23-179 k23-180 k23-181 k23-182 k23-183 k23-184 k23-185 k23-186 k23-187 k23-189 k23-190 k23-192 k23-193 k23-195 k23-196 k23-197 k23-198"
    '';
    plugins = [
      {
        name = "zsh-bash-completions-fallback";
        src = ./../../../src/zsh-bash-completions-fallback;
#         src = pkgs.fetchFromGitHub {
#           owner = "3v1n0";
#           repo = "zsh-bash-completions-fallback";
#           rev = "fa70a4382cae49aebe9e888315d40b0f26aab42b";
#           sha256 = "0247zz6qd43j981vcz40xvaj0na83wzznfrl4i1plbalvpczkkz3";
#         };
      }
    ];

  };

  programs.emacs = {
    enable = true;

#     # Not used since switch to straight
#     extraPackages = epkgs: with epkgs; [ edit-server magit forge nix-mode direnv vterm pod-mode ];
    extraPackages = epkgs: with epkgs; [ vterm ];

    package = (pkgs.emacs.override {
      withGTK2 = false;
      withGTK3 = false;
      Xaw3d = pkgs.xorg.libXaw3d;
      # lucid -> lucid
    }).overrideAttrs(old: {
      dontStrip = true;
      #separateDebugInfo = true;
    });
  };

  programs.fzf = {
    enable = true;
    defaultOptions = [ "--bind ctrl-k:kill-line --color=dark" ];
  };

  programs.dircolors.enable = true;

  programs.direnv.enable = true;

  programs.go.enable = true;

  programs.obs-studio.enable = true;
  programs.obs-studio.plugins = with pkgs; [
    #obs-v4l2sink # built into OBS since 26.1
    #(callPackage ./obs-shaderfilter-plus.nix {})
    #(callPackage ~/src/obs/obs-shaderfilter/obs-shaderfilter.nix {})
  ];

  services.gpg-agent.enable = true;
  services.lorri.enable = true;

  systemd.user.services = {
    git-annex-assistant = {
      Unit = {
        Description = "Git Annex Assistant";
      };

      Service = {
        Environment = "PATH=${pkgs.git}/bin:%h/.nix-profile/bin";
        ExecStart = "${pkgs.gitAndTools.git-annex}/bin/git-annex assistant --autostart --startdelay 60 --notify-start --notify-finish --foreground";
        ExecStop = "${pkgs.gitAndTools.git-annex}/bin/git-annex assistant --autostop";
        #LimitCPU = "10m";
        CPUAccounting = true;
        CPUQuota = "20%";
        Restart = "on-failure";
        RestartSec = "5s";
      };

      Install = { WantedBy = [ "default.target" ]; };
    };

    backup-etc-git = {
      Unit = {
        Description = "Backup etc git from servers";
      };
      Service = {
        ExecStart = "${pkgs.git}/bin/git --git-dir=%h/srv/etc fetch --all";
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
