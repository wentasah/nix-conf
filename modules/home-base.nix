{ config, pkgs, lib, ... }:
# Basic home manager configuration common to all my systems. Mostly
# CLI utilities.
let
  globalPythonPackages = (pp: with pp; [
    requests urllib3 # for filesender.py
    matplotlib tkinter
    flake8 flake8-bugbear isort
  ]);
  lazydocs = pkgs.callPackage ../pkgs/lazydocs.nix { };
in
{
  imports = [
    ./verilog.nix
    ./emacs.nix
  ];
  home.packages = with pkgs; [
    act
    age
    alejandra
    aspell
    aspellDicts.cs
    aspellDicts.en
    aspellDicts.en-computers
    aspellDicts.en-science
    atop
    attic-client
    bat
    bbe
    bc                          # For linux kernel compilation
    black
    black-macchiato
    boxes
    btdu
    btop
    cachix
    ccls
    cloc
    cmake-language-server
    colmena
    colordiff
    colorized-logs
    crate2nix
    csv2latex
    csvtool
    d2
    daemontools
    delta
    dix
    dot-language-server
    doxygen_gui
    dua
    elfutils
    entr
    eza
    fd
    ffmpeg
    filterpath
    findrepo
    gcalcli
    gdb
    gh
    git-backdate
    git-cliff
    git-filter-repo
    git-lfs
    git-machete
    git-subtrac
    gitbatch
    gitui
    glab
    glibc.static                # to allow gcc -static
    global
    glow
    gnumake
    gnupg
    gpg-tui
    graphviz
    help2man
    (lib.hiPrio outils)   # collides with ts from moreutils
    (lib.hiPrio parallel) # Prefer this over parallel from moreutils
    home-manager
    htop
    hunspellDicts.cs_CZ
    hunspellDicts.en_US
    hydra-check
    hyperfine
    imagemagick
    jo
    jq
    just
    lazydocs
    lemminx
    libxml2 # for xmllint
    live-server
    ltrace
    magic-wormhole
    mailutils
    man-pages-posix
    marksman
    mc
    mcap-cli
    mdcat
    mdsh
    meson
    ministat
    moreutils
    mosh
    mtr
    ncdu
    nh
    nil
    ninja
    niv
    nix-bisect
    nix-diff
    nix-doc
    nix-du
    nix-eval-jobs
    nix-fast-build
    nix-init
    nix-inspect
    nix-output-monitor
    nix-prefetch
    nix-prefetch-scripts
    nix-template
    nix-tree
    nix-update
    nixfmt-rfc-style
    nixos-generators
    nixos-shell
    nixpkgs-review
    nodePackages.bash-language-server
    npins
    nurl
    odt2txt
    oils-for-unix
    p7zip
    pandoc
    pastel
    pdf2svg
    pdfgrep
    pdftk
    pkg-config
    polylux2pdfpc
    poppler-utils
    psmisc                      # killall, fuser, ...
    pv
    pyright
    (python3.withPackages globalPythonPackages)
    python3Packages.invoke
    python3Packages.python-lsp-server
    rainfrog
    ranger
    redo-apenwarr
    repgrep
    restic
    ripgrep
    #rnix-lsp # needs insecure nix-2.15.3
    ros2nix
    rsync
    ruff
    rush-parallel
    sd
    sequoia-sq
    serie
    shdw
    shellcheck
    socat
    sops
    sqlite-interactive
    ssh-to-age
    sshfs
    sshuttle
    sta
    systemctl-tui
    tectonic
    tig
    tinymist # alternative typst LSP
    tmux
    tokei
    trace-cmd
    (tree-sitter.withPlugins (_: tree-sitter.allGrammars))
    treefmt
    typst
    typstfmt
    uncrustify
    unzip
    update-nix-fetchgit
    valgrind
    vcstool
    waypipe
    websocat
    xmlstarlet
    yamllint
    yq-go
    yubikey-manager
    zip
    zsh-completions
    zsh-syntax-highlighting

    cargo-edit
    cargo-expand
    # rust-analyzer # already in rustup
    # rustc cargo rls clippy
    rustup
  ];

  home.file = {
    ".config/bat/config".text = ''
        --theme=gruvbox-light
    '';
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
    "bin/nix-develop-pure" = let
      bashrc = pkgs.writeText "bashrc" ''
        PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
      '';
    in {
      executable = true;
      text = ''
        #!${pkgs.runtimeShell}
        KEEP=(NOSYSBASHRC HOME USER LOGNAME DISPLAY TERM IN_NIX_SHELL NIX_SHELL_PRESERVE_PROMPT TZ PAGER NIX_BUILD_SHELL SHLVL)
        if true; then
            export NOSYSBASHRC=1  # Needed to ignore /etc/bashrc on NixOS
            exec nix develop --ignore-environment ''${KEEP[@]/*/--keep &} --command bash --rcfile ${bashrc}
        else
            exec nix develop --ignore-environment ''${KEEP[@]/*/--keep &} --command bash --norc
        fi
      '';
    };
  };

  home.sessionVariables = {
    # I have a problem with zsh when EDITOR is "vim". Pressing "delete"
    # prints "~" instead of deleting a char. For details why see:
    #
    #     EDITOR=vi zsh -i -c 'bindkey -e; bindkey' > key.vi
    #     EDITOR=em zsh -i -c 'bindkey -e; bindkey' > key.em
    #     diff -u --color key.vi key.em
    # The result should be same, but it isn't.
    EDITOR = "emacsclient-tty";
    JULIA_EDITOR = "emacsclient";
    GIT_PAGER = "less -FRX";    # overrides PAGER set by oh-my-zsh
    SYSTEMD_COLORS = 16;        # don't use yellow color (from 256-color palette) on white background
  };

  home.sessionPath = [ "$HOME/bin" ];

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
      j     = "julia --project --thread=auto";
      jc    = "journalctl";
      jcu   = "journalctl --user";
      kssh  = "kitty +kitten ssh";
      l     = "eza -la --group --header --time-style=relative --hyperlink";
      lg    = "eza -la --group --header --time-style=relative --hyperlink --git";
      lt    = "eza -la --group --header --time-style=relative --hyperlink --tree";
      ln    = "nocorrect ln"; # no spelling correction on ln
      lnr   = "nocorrect ln -s --relative";
      ls    = "ls --color=auto";
      lsa   = "ls -ld .*"; # List only file beginning with "."
      lsd   = "ls -ld *(-/DN)"; # List only directories and symbolic links that point to directories
      mkdir = "nocorrect mkdir"; # no spelling correction on mkdir
      mv    = "nocorrect mv"; # no spelling correction on mv
      sc    = "systemctl";
      scp   = "${pkgs.rsync}/bin/rsync -aP --inplace";
      scs   = "systemctl status";
      scu   = "systemctl --user";
      scus  = "scu status";
      sudo  = "nocorrect sudo";
      touch = "nocorrect touch";
      which = "nocorrect which";
      zz    = "__zoxide_zi \"$@\"";
    };
    oh-my-zsh = {
      enable = true;
    };
    syntaxHighlighting = {
      enable = true;
      highlighters = [ "main" "brackets" ];
    };
    initContent = let
      zshConfigEarlyInit = lib.mkOrder 550 ''
        # Make tramp work (https://www.gnu.org/software/emacs/manual/html_node/tramp/Frequently-Asked-Questions.html)
        [[ $TERM == "dumb" ]] && unsetopt zle && PS1='$ ' && return

        # Where to look for autoloaded function definitions
        fpath=(~/.zfunc $fpath)
      '';
      zshConfig = ''
        source ${../pkgs/zsh-config/zshrc}
        source ${pkgs.mc}/libexec/mc/mc.sh
        source ${../pkgs/zsh-config/nix-direnv}

        # Setup ROS 2 auto completion for nix-direnv environments
        eval "$(${pkgs.python3Packages.argcomplete}/bin/register-python-argcomplete -s zsh ros2)"
        eval "$(${pkgs.python3Packages.argcomplete}/bin/register-python-argcomplete -s zsh colcon)"
      '';
    in
      lib.mkMerge [ zshConfigEarlyInit zshConfig ];

  };

  programs.atuin = {
    enable = true;
    enableBashIntegration = true;
    enableZshIntegration = true;
    flags = [
      "--disable-up-arrow"
    ];
    settings = {
      history_filter = [
        # Ignore commands from Emacs Tramp
        "HISTFILE=~/.tramp_history"
      ];
    };
  };

  programs.starship = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.zellij.enable = true;

  programs.bash = {
    enable = true;
    initExtra = ''
      if test -n "$KITTY_INSTALLATION_DIR"; then
          export KITTY_SHELL_INTEGRATION="enabled"
          source "$KITTY_INSTALLATION_DIR/shell-integration/bash/kitty.bash"
      fi
    '';
  };

  programs.fzf = {
    enable = true;
    defaultOptions = [ "--bind ctrl-k:kill-line --color=dark" ];
    # I keep fzf enabled with atuin, because I use fzf-cd-widget.
    # Ctrl-R gets correctly overridden by atuin.
  };

  programs.dircolors.enable = true;

  programs.direnv.enable = true;
  # https://github.com/direnv/direnv/wiki/Customizing-cache-location#human-readable-directories
  programs.direnv.stdlib = ''
    : ''${XDG_CACHE_HOME:=$HOME/.cache}
    declare -A direnv_layout_dirs
    direnv_layout_dir() {
      echo "''${direnv_layout_dirs[$PWD]:=$(
        local hash="$(sha1sum - <<<"''${PWD}" | cut -c-7)"
        local pwd_=''${PWD#/}
        local path="''${pwd_//[^a-zA-Z0-9]/-}"
        echo "''${XDG_CACHE_HOME}/direnv/layouts/''${path}-''${hash}"
      )}"
    }
  '';
  programs.direnv.nix-direnv.enable = true;

  programs.yazi = let
    # See https://yazi-rs.github.io/docs/installation#nix
    yazi-plugins = pkgs.fetchFromGitHub {
      owner = "yazi-rs";
      repo = "plugins";
      rev = "55bf6996ada3df4cbad331ce3be0c1090769fc7c";
      hash = "sha256-v/C+ZBrF1ghDt1SXpZcDELmHMVAqfr44iWxzUWynyRk=";
      # date = "2025-05-11T13:21:13+08:00";
    };
  in {
    enable = true;
    enableBashIntegration = true;
    enableZshIntegration = true;
    settings = {
      manager = {
        show_hidden = true;
      };
      opener = {
        edit = [ { run = "ec \"$@\""; desc = "Edit with ec"; block = true; for = "unix"; } ];
      };
    };
    keymap = {
      manager.prepend_keymap = [
        {on = "<Delete>"; run = "remove";}
        {on = "<Enter>"; run = "plugin --sync smart-enter"; desc = "Enter the child directory, or open the file";}
        {on = "<S-Delete>"; run = "remove --permanently";}
        {on = "y"; run = [''yank'' ''shell 'for path in "$@"; do echo "file://$path"; done | wl-copy -t text/uri-list' --confirm''];}
        {on = [ "c" "m" ]; run  = "plugin chmod"; desc = "Chmod on selected files"; }
      ];
    };
    plugins = {
      chmod = "${yazi-plugins}/chmod.yazi";
      git = "${yazi-plugins}/git.yazi";
      smart-enter = "${yazi-plugins}/smart-enter.yazi";
    };
  };

  programs.zoxide = {
    enable = true;
    enableBashIntegration = true;
    enableZshIntegration = true;
  };

  xdg.configFile = {
    "mc/mc.ext.ini".text = ''
      ${builtins.readFile "${pkgs.mc}/etc/mc/mc.ext.ini"}
      [mcap]
      Open=foxglove-studio %f >/dev/null 2>&1 &
      Shell=.mcap
   '';
    "mc/menu".text = ''
      ${builtins.readFile "${pkgs.mc}/etc/mc/mc.menu"}
      e       Edit with Emacs (X or text)
              ec %f

      a       Send as attachment (notmuch)
              notmuch-attach %s

      p       Copy full file path to clipboard
              wl-copy "%d/%f"

      k       KDiff3
              kdiff3 %D/%F %f
    '';
  };

  services.home-manager.autoExpire = {
    enable = true;
    timestamp = "-7 days";
    frequency = "weekly";
  };
}
