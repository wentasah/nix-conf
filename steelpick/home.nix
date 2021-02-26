{ config, pkgs, ... }:

let
  lib = pkgs.lib;
  firejailedBinaries = {        # TODO: create wrapper automatically
#     slack = "${pkgs.slack}/bin/slack";
#     teams = "${pkgs.teams}/bin/teams";
#     skypeforlinux = "${pkgs.skypeforlinux}/bin/skypeforlinux";
  };
  mytexlive = pkgs.texlive.combine {
    inherit (pkgs.texlive) scheme-basic scheme-medium collection-langczechslovak
      collection-xetex latexmk collection-latexextra
      collection-mathscience chktex roboto cbfonts IEEEconf;
    pkgFilter = (pkg:
      pkg.tlType == "run"
      || pkg.tlType == "bin"
      || (
        pkg.tlType == "doc" &&
        # Prevent collisions
        !builtins.elem pkg.pname [ "dvipdfmx" "texlive-scripts" ]
      ));
  };
  julia = import ../pkgs/julia-bin.nix { pkgs = pkgs; };
  lexicon = import ../pkgs/lexicon.nix { pkgs = pkgs; };
  cppreference = import ../pkgs/cppreference.nix { pkgs = pkgs; };
  pod-mode = import ../pkgs/pod-mode.nix { pkgs = pkgs; };
  gtkterm = import ../pkgs/gtkterm.nix { pkgs = pkgs; };
  stm32cubeide = import ../pkgs/stm32cubeide { pkgs = pkgs; };
  licenseutils = import ../pkgs/licenseutils { pkgs = pkgs; };
in
{
  nixpkgs = {
    config = {
      allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
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
    #firejail
    #gnome3.nautilus
    #gtkterm
    #jupyter
    #slack
    #teams
    (binutils-unwrapped.override { withAllTargets = true; enableShared = false; }) # https://github.com/NixOS/nixpkgs/issues/82792
    (hiPrio gcc) # Prio over clang's c++ etc
    (hiPrio parallel) # Prefer this over parallel from moreutils
    (qtcreator.override { withClangPlugins = false; }) # too old in nixpkgs - patched in my local copy
    afew
    arandr
    ardour jack2 x42-plugins gxplugins-lv2 qjackctl
    aspell
    aspellDicts.cs
    aspellDicts.en
    aspellDicts.en-computers
    aspellDicts.en-science
    atool
    audacity
    audacity
    autorandr
    bbe
    brightnessctl
    cachix
    ccls
    chromium
    clang
    clang-tools
    clementine
    clinfo
    cmake
    colordiff
    cppreference
    dpkg
    dragon-drop
    dunst
    exif
    fd
    ffmpeg
    firefox
    gdb
    gimp
    gitAndTools.git-annex
    gitAndTools.git-subtrac
    gitAndTools.tig
    glibcInfo                   # Not visible in emacs :-(
    global
    gnome3.devhelp
    gnome3.libsecret
    gnumake
    gnupg
    gnuplot_qt
    gtkterm
    htop
    hugo
    i3status-rust font-awesome_4 powerline-fonts
    imagemagick
    inkscape
    isync
    jq
    julia
    kdiff3
    keepassxc
    kicad-small
    lexicon
    libnotify # for notify-send (for mailsync)
    libreoffice-fresh
    licenseutils
    linuxPackages.perf
    lsof # TODO: git-annex assistant should depend on this
    ltrace
    manpages
    mc
    meson
    moreutils
    mosh
    mtr
    musescore
    mytexlive
    nasm
    ncdu
    ninja
    niv
    nix-prefetch-scripts
    nix-review
    notmuch
    notmuch.emacs
    odt2txt
    okteta
    okular
    openssl
    p7zip
    pandoc
    parcellite
    pavucontrol
    pdf2svg
    perlPackages.AppClusterSSH
    perlPackages.Expect.devdoc         # manpage for novaboot development
    pidgin
    pkg-config
    playerctl
    pod-mode
    poppler_utils
    psmisc                      # killall, fuser, ...
    pv
    python3
    python3Packages.jupyter_core
    python3Packages.notebook
    qemu
    qt5.full            # To make qtcreator find the qt automatically
    radare2 radare2-cutter
    ranger
    redo-apenwarr
    restic
    ripgrep
    roboto-slab
    rofi
    rsync
    shellcheck
    shotcut
    smplayer mpv mplayer
    socat
    solvespace
    sshuttle
    stm32cubeide
    thunderbird
    tmux
    unzip
    usbutils
    v4l-utils # for qv4l2
    valgrind
    vlc
    wmctrl
    xclip
    xdotool
    xf86_input_wacom
    xorg.xev
    xorg.xkbcomp
    xorg.xkill
    xournal
    xournalpp
    xpra
    xss-lock
    zip
    zotero
    zsh-completions
    zsh-syntax-highlighting
    (import ../pkgs/unfs3 { pkgs = pkgs; })

    (swaylock.overrideAttrs(old: {
      src = fetchFromGitHub {
        owner = "swaywm";
        repo = "swayidle";
        rev = "068942751ba459ef3b9ba0ec8eddf9f6f212c4d7";
        # date = 2020-11-06T11:38:15+01:00;
        sha256 = "1ml2n1rp8simpd2y4ff1anx2vj89f3a6dhfz8m2hdan749vwnxvk";
      };
      buildInputs = old.buildInputs ++ [ systemd ];
    }))

    # Fonts
    roboto
    source-sans-pro

  ] ++ lib.attrVals (builtins.attrNames firejailedBinaries) pkgs;

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
    GIT_PAGER = "less -FRX";    # overrides PAGER set by oh-my-zsh
    NIX_PATH = "nixpkgs=$HOME/nix/nixpkgs:$NIX_PATH";
  };

  xsession = {
    enable = true;
    scriptPath = ".xsession-hm";
    numlock.enable = true;
    windowManager.i3 = {
      enable = true;
      config = null; # Do not generate config with home-manager
      extraConfig = "${builtins.readFile "${config.home.homeDirectory}/.i3/config"}";
    };
  };

  programs.man.enable = true;
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
      r     = "ranger";
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
    extraPackages = epkgs: with epkgs; [
      edit-server
      helm
      magit
      forge
      nix-mode
      eglot
      direnv
      vterm
      pod-mode
    ];
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

  programs.obs-studio.enable = true;
  programs.obs-studio.plugins = with pkgs; [
    #obs-v4l2sink # built into OBS since 26.1
    #(callPackage ./obs-shaderfilter-plus.nix {})
    #(callPackage ~/src/obs/obs-shaderfilter/obs-shaderfilter.nix {})
  ];

  services.gpg-agent.enable = true;
  services.lorri.enable = true;

  services.network-manager-applet.enable = true;
  systemd.user.services.network-manager-applet.Service = {
    # Handle crashes after xrandr or i3 restarts: https://github.com/NixOS/nixpkgs/issues/99197
    Restart = "on-failure";
    RestartSec = 5;
  };

  services.dunst = {
    enable = true;
    settings = {
      global = {
        follow = "mouse";
        geometry = "300x5-30+20";
        padding = 8;
        horizontal_padding = 8;
        frame_width = 3;
        frame_color = "#aaaaaa";
        idle_threshold = 120;
        font = "Cantarel 8";
        markup = "full";
        format = "<b>%s</b>\\n%b\\n%p";
        show_age_threshold = 60;
        word_wrap = true;
        max_icon_size = 32;
        icon_position = "left"; # Trying it
        dmenu = "${pkgs.rofi}/bin/rofi -dmenu -p Dunst";
        browser = "${pkgs.firefox}/bin/firefox";
      };
      # TODO: Replace with dunstctl
      shortcuts = {
        close = "mod4+Escape";
        history = "mod4+shift+Escape";
        context = "mod4+shift+period";
      };

      urgency_low = {
        background = "#222222";
        foreground = "#888888";
        timeout = 10;
        # Icon for notifications with low urgency, uncomment to enable
        #icon = /path/to/icon
      };

      urgency_normal = {
        background = "#285577";
        foreground = "#ffffff";
        timeout = 10;
        # Icon for notifications with normal urgency, uncomment to enable
        #icon = /path/to/icon
      };
      urgency_critical = {
        background = "#900000";
        foreground = "#ffffff";
        frame_color = "#ff0000";
        timeout = 0;
        # Icon for notifications with critical urgency, uncomment to enable
        #icon = /path/to/icon
      };
    };
  };

  systemd.user.services = {
    git-annex-assistant = {
      Unit = {
        Description = "Git Annex Assistant";
      };

      Service = {
        ExecStart = "${pkgs.gitAndTools.git-annex}/bin/git-annex assistant --autostart --startdelay 60 --notify-start --notify-finish --foreground";
        ExecStop = "${pkgs.gitAndTools.git-annex}/bin/git-annex assistant --autostop";
        #LimitCPU = "10m";
        CPUAccounting = true;
        CPUQuota = "20%";
        Restart = "on-failure";
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

    parcellite = {
      Unit = {
        Description = "Parcellite";
        After = [ "graphical-session-pre.target" ];
        PartOf = [ "graphical-session.target" ];
      };

      Install = { WantedBy = [ "graphical-session.target" ]; };

      Service = {
        ExecStart = "${pkgs.parcellite}/bin/parcellite";
        # Handle crashes after xrandr or i3 restarts: https://github.com/NixOS/nixpkgs/issues/99197
        Restart = "on-failure";
        RestartSec = 5;
      };
    };

    ncdu-save = {
      Service = {
        ExecStart = "${pkgs.gnumake}/bin/make -C %h/srv/steelpick/ncdu save";
      };
    };
  };

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
