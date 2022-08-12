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
  julia = pkgs.julia-stable-bin; # import ../pkgs/julia-bin.nix { pkgs = pkgs; };
  lexicon = import ../pkgs/lexicon.nix { pkgs = pkgs; };
  cppreference = import ../pkgs/cppreference.nix { pkgs = pkgs; };
  pod-mode = import ../pkgs/pod-mode.nix { pkgs = pkgs; };
  stm32cubeide = import ../pkgs/stm32cubeide { pkgs = pkgs; };
  licenseutils = import ../pkgs/licenseutils { pkgs = pkgs; };
  #kernelshark = import ../pkgs/kernelshark { pkgs = pkgs; };
  julia-wrapper = pkgs.callPackage ../pkgs/julia-wrapper { inherit julia; };
  globalPythonPackages = (pp: with pp; [
    requests urllib3 # for filesender.py
    matplotlib
  ]);
in
{
  imports = [
    ../modules/i3.nix
    ../modules/gdu.nix
    ../modules/go.nix
    ../modules/git-annex.nix
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
    #(pkgs.callPackage ../pkgs/diffsitter {})
    #(qtcreator.override { withClangPlugins = false; }) # too old in nixpkgs - patched in my local copy
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
    (hiPrio parallel) # Prefer this over parallel from moreutils
    (ikiwiki.override { docutilsSupport = true; })
    (import ../pkgs/unfs3 { pkgs = pkgs; })
    (pkgs.callPackage ../pkgs/cargo-prefetch {})
    (pkgs.callPackage ../pkgs/difftastic {})
    (pkgs.callPackage ../pkgs/enumerate-markdown {})
    (python3.withPackages globalPythonPackages)
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
    auto-multiple-choice
    automake
    avidemux
    bbe
    bc                          # For linux kernel compilation
    bear
    binutils-unwrapped-all-targets
    bison
    bubblewrap
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
    #cutter # currently broken
    daemontools
    dpkg
    drawio
    dua
    dunst
    easyeffects
    entr
    exa
    exif
    fd
    fdupes
    ffmpeg
    firefox #-devedition-bin # I need devedition to use (currently) unrelease version of https://github.com/stsquad/emacs_chrome
    flameshot
    flex
    flowblade
    #freecad # broken
    gdb
    gh
    gimp
    git-machete
    gitAndTools.delta
    gitAndTools.git-lfs
    gitAndTools.git-subtrac
    gitAndTools.tig
    gitbatch
    gitui
    glibcInfo                   # Not visible in emacs :-(
    global
    gnome3.devhelp
    gnumake
    gnupg
    gpg-tui
    gtkterm
    hdf5
    help2man
    hotspot
    htop
    hugo
    hunspellDicts.cs_CZ
    hunspellDicts.en_US
    imagemagick
    inkscape
    isync
    jq
    julia-wrapper
    kdiff3
    keepassxc
    kernelshark
    kicad-small
    krita
    lazydocker
    lexicon
    libev # to have the man page ready
    libnotify # for notify-send (for mailsync)
    libreoffice-fresh
    libsecret
    libxml2 # for xmllint
    licenseutils
    linuxPackages.perf
    lsof # TODO: git-annex assistant should depend on this
    ltrace
    man-pages
    mc
    meld
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
    nix-autobahn
    nix-doc
    nix-index
    nix-output-monitor
    nix-prefetch
    nix-prefetch-scripts
    nix-review
    nix-template
    nix-tree
    nixfmt
    nixos-generators
    nixos-shell
    nixpkgs-fmt
    nodePackages.markdownlint-cli
    nodePackages.typescript-language-server
    novaboot                    # from novaboot overlay
    notify-while-running
    notmuch
    notmuch.emacs
    nvd
    odt2txt
    oil
    okteta
    okular
    openssl
    openssl.dev                 # For linux kernel compilation
    p7zip
    pandoc
    pavucontrol
    pdf2svg
    pdfpc
    pdftk
    perl.devdoc
    perlPackages.AppClusterSSH
    perlPackages.Expect.devdoc         # manpage for novaboot development
    pidgin
    pkg-config
    playerctl
    pod-mode
    poppler_utils
    posix_man_pages
    psmisc                      # killall, fuser, ...
    pulseaudio                  # I use pactl in ~/.i3/config (even with pipewire)
    pv
    python3Packages.jupyter_core
    python3Packages.notebook
    python3Packages.python-lsp-server
    qemu
    qt5.full            # To make qtcreator find the qt automatically
    qtcreator
    radare2
    ranger
    redo-apenwarr
    restic
    ripgrep
    rnix-lsp
    rsync
    saleae-logic-2
    screenkey
    sequoia
    shellcheck
    shotcut
    smplayer mpv mplayer
    socat
    solvespace
    sops
    sqlite-interactive
    sqlitebrowser
    sshuttle
    sterm
    stm32cubeide
    tcpreplay
    thunderbird
    tmux
    trace-cmd
    unrar
    unzip
    usbrelay
    usbutils
    v4l-utils # for qv4l2
    valgrind
    vlc
    websocat
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
    yamllint
    yq
    zip
    zotero
    zsh-completions
    zsh-syntax-highlighting
    zulip
    #zulip-term #broken

    # Emacs versions from emacs-overlay
    (pkgs.writeShellScriptBin "emacs-27"       ''exec ${emacs}/bin/emacs "$@"'')
    (pkgs.writeShellScriptBin "emacs-unstable" ''exec ${emacsUnstable}/bin/emacs "$@"'')
    (pkgs.writeShellScriptBin "emacs-pgtk-gcc" ''exec ${emacsPgtkGcc}/bin/emacs "$@"'')

    rustup
    # rustc cargo rls clippy
    rust-analyzer cargo-edit

    # Fonts
    roboto-slab
    roboto
    source-sans
    source-sans-pro
    source-serif
    source-serif-pro
    lato
    open-sans
    libertine # For images consistency with ACM latex template
    #iosevka # broken https://github.com/NixOS/nixpkgs/issues/185633

  ]
  ++ lib.attrVals (builtins.attrNames firejailedBinaries) pkgs
  ++ (with pkgsCross.aarch64-multiplatform; [
    buildPackages.gcc
    (lib.setPrio 20 buildPackages.bintools-unwrapped) # aarch64-unknown-linux-gnu-objdump etc.
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
      # Find the link target recursively. Note that $(whix ls) differs
      # from $(readlink -f $(which ls)). The former is
      # /nix/store/py4fwm34anmxg3vr6832cv2mil70hy9f-coreutils-9.0/bin/ls
      # while the later (becase ls is symlink to coreutils)
      # /nix/store/py4fwm34anmxg3vr6832cv2mil70hy9f-coreutils-9.0/bin/coreutils
      text = ''
        #!${pkgs.runtimeShell}
        target=$(command which "$1")
        while [[ -L $target ]]; do target=$(readlink -f "$target"); done
        echo "$target"
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
      gm    = "git machete";
      grep  = "grep --color";
      gst   = "git status";
      h     = "history";
      j     = "julia --project";
      jc    = "journalctl";
      l     = "exa -la --group --git --header";
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
    initExtraBeforeCompInit = ''
      # Where to look for autoloaded function definitions
      fpath=(~/.zfunc $fpath)
    '';
    initExtra = ''
      DIRSTACKSIZE=100

      setopt notify interactivecomments recexact longlistjobs
      setopt autoresume pushdsilent autopushd pushdminus

      d() {
        local dir
        dir=$(dirs -l -p | fzf +m) &&
        cd $dir
      }

      gcd() {
        local dir="$(git ls-tree -d -r --name-only --full-name HEAD $(git rev-parse --show-cdup) | fzf +m -0)" &&
        cd "./$(git rev-parse --show-cdup)/$dir"
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

      source ${../pkgs/zsh-config/nix-direnv}

      # Integrate run-nix-help (https://github.com/NixOS/nix/blob/master/misc/zsh/run-help-nix#L14)
      (( $+aliases[run-help] )) && unalias run-help
      autoload -Uz run-help run-help-nix

      # Hostnames in K23 lab
      k23="k23-177 k23-178 k23-179 k23-180 k23-181 k23-182 k23-183 k23-184 k23-185 k23-186 k23-187 k23-189 k23-190 k23-192 k23-193 k23-195 k23-196 k23-197 k23-198"
    '';
#     plugins = [
#       {
#         name = "zsh-bash-completions-fallback";
#         src = ./../../../src/zsh-bash-completions-fallback;
#         src = pkgs.fetchFromGitHub {
#           owner = "3v1n0";
#           repo = "zsh-bash-completions-fallback";
#           rev = "fa70a4382cae49aebe9e888315d40b0f26aab42b";
#           sha256 = "0247zz6qd43j981vcz40xvaj0na83wzznfrl4i1plbalvpczkkz3";
#         };
#       }
#     ];

  };

  programs.emacs = {
    enable = true;

#     # Not used since switch to straight
#     extraPackages = epkgs: with epkgs; [ edit-server magit forge nix-mode direnv vterm pod-mode ];
    extraPackages = epkgs: with epkgs; [
      vterm
      pdf-tools
      melpaPackages.julia-mode # for ikiwiki-org-plugin in my blog
    ];

    package = (
      if true then
        pkgs.emacsNativeComp
        # pkgs.emacs.override {
#           withGTK2 = false;
#           withGTK3 = false;
#           Xaw3d = pkgs.xorg.libXaw3d;
#           # lucid -> lucid
#         }
      else
        pkgs.emacsPgtkGcc
    ).overrideAttrs(old: {
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
  programs.direnv.nix-direnv.enable = true;

  programs.obs-studio.enable = true;
  programs.obs-studio.plugins = with pkgs; [
    #obs-v4l2sink # built into OBS since 26.1
    #(callPackage ./obs-shaderfilter-plus.nix {})
    #(callPackage ~/src/obs/obs-shaderfilter/obs-shaderfilter.nix {})
  ];

  services.xsettingsd.enable = true;
  services.gpg-agent.enable = true;
  services.gpg-agent.enableExtraSocket = true;
  services.lorri.enable = true;

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
