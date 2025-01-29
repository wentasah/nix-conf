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
  ];
  home.packages = with pkgs; [
    age
    alejandra
    aspell
    aspellDicts.cs
    aspellDicts.en
    aspellDicts.en-computers
    aspellDicts.en-science
    atop
    bat
    bbe
    bc                          # For linux kernel compilation
    black
    black-macchiato
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
    doxygen_gui
    dua
    entr
    eza
    fd
    ffmpeg
    findrepo
    gcalcli
    gdb
    gh
    git-backdate
    git-cliff
    git-filter-repo
    git-machete
    gitAndTools.delta
    gitAndTools.git-lfs
    gitAndTools.git-subtrac
    gitAndTools.tig
    gitbatch
    gitui
    glab
    global
    glow
    gnumake
    gnupg
    gpg-tui
    graphviz
    help2man
    (hiPrio parallel) # Prefer this over parallel from moreutils
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
    nil
    ninja
    niv
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
    nvd
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
    poppler_utils
    psmisc                      # killall, fuser, ...
    pv
    pyright
    (python3.withPackages globalPythonPackages)
    python3Packages.invoke
    python3Packages.python-lsp-server
    ranger
    redo-apenwarr
    restic
    ripgrep
    #rnix-lsp # needs insecure nix-2.15.3
    ros2nix
    rsync
    ruff
    sd
    sequoia
    shdw
    shellcheck
    socat
    sops
    sqlite-interactive
    ssh-to-age
    sshfs
    sshuttle
    sta
    tectonic
    tinymist # alternative typst LSP
    tmux
    trace-cmd
    (tree-sitter.withPlugins (_: tree-sitter.allGrammars))
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
    "bin/ec" = {
      executable = true;
      text = ''
        #!${pkgs.runtimeShell}
        [[ $DISPLAY$WAYLAND_DISPLAY ]] && args="--no-wait ''${1:---create-frame}" || args="--tty"
        exec ${config.programs.emacs.package}/bin/emacsclient $args -a  "" "$@"
      '';
    };
    "bin/emacsclient-tty" = {
      executable = true;
      text = ''
        #!${pkgs.runtimeShell}
        exec ${config.programs.emacs.package}/bin/emacsclient -t "$@"
      '';
    };
    "bin/magit" = {
      executable = true;
      text = ''
        #!${pkgs.runtimeShell}
        exec ~/bin/ec -e "(magit \"$(git rev-parse --show-toplevel)\")" "$@"
      '';
    };
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
    initExtraBeforeCompInit = ''
      # Make tramp work (https://www.gnu.org/software/emacs/manual/html_node/tramp/Frequently-Asked-Questions.html)
      [[ $TERM == "dumb" ]] && unsetopt zle && PS1='$ ' && return

      # Where to look for autoloaded function definitions
      fpath=(~/.zfunc $fpath)
    '';
    initExtra = ''
      source ${../pkgs/zsh-config/zshrc}
      source ${pkgs.mc}/libexec/mc/mc.sh
      source ${../pkgs/zsh-config/nix-direnv}

      # Setup ROS 2 auto completion for nix-direnv environments
      eval "$(${pkgs.python3Packages.argcomplete}/bin/register-python-argcomplete -s zsh ros2)"
      eval "$(${pkgs.python3Packages.argcomplete}/bin/register-python-argcomplete -s zsh colcon)"
    '';
  };

  programs.starship = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.bash = {
    enable = true;
    initExtra = ''
      if test -n "$KITTY_INSTALLATION_DIR"; then
          export KITTY_SHELL_INTEGRATION="enabled"
          source "$KITTY_INSTALLATION_DIR/shell-integration/bash/kitty.bash"
      fi
    '';
  };

  programs.emacs = {
    enable = true;

#     # Not used since switch to straight
#     extraPackages = epkgs: with epkgs; [ edit-server magit forge nix-mode direnv vterm pod-mode ];
    extraPackages = epkgs: with epkgs; [
    ];

    package = let
      emacsWithPackages = (pkgs.emacsPackagesFor ((
        pkgs.emacs
        #pkgs.emacs-unstable
        #pkgs.emacsGit
          .override {
            # withGTK2 = false;
            # withGTK3 = false;
            # Xaw3d = pkgs.xorg.libXaw3d;
            # # lucid -> lucid
            withPgtk = true;
          }
      )
#       .overrideAttrs(old: {
#         #dontStrip = true;
#         separateDebugInfo = true;
#         passthru = old.passthru // {
#           withTreeSitter = true;
#         };
#       })
      )).emacsWithPackages;
    in
      emacsWithPackages (epkgs: (with epkgs.melpaStablePackages; [
        all-the-icons
        #forge # broken (emacsql> /nix/store/...-stdenv-linux/setup: line 227: pushd: sqlite: No such file or directory)
        magit
      ]) ++ (with epkgs.melpaPackages; [
        direnv
        julia-mode # for ikiwiki-org-plugin in my blog
        nix-mode
        vterm
        pdf-tools
      ]) ++ (with epkgs.elpaPackages; [
        jinx
      ]) ++ (if epkgs.manualPackages ? treesit-grammars then [
        epkgs.manualPackages.treesit-grammars.with-all-grammars
      ] else []) ++[
        pkgs.notmuch   # From main packages set
      ]);
  };
  services.emacs = {
    enable = true;
    socketActivation.enable = true;
  };

  programs.fzf = {
    enable = true;
    defaultOptions = [ "--bind ctrl-k:kill-line --color=dark" ];
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
        local path="''${PWD//[^a-zA-Z0-9]/-}"
        echo "''${XDG_CACHE_HOME}/direnv/layouts/''${hash}''${path}"
      )}"
    }
  '';
  programs.direnv.nix-direnv.enable = true;

  programs.yazi = {
    enable = true;
    enableBashIntegration = true;
    enableZshIntegration = true;
# Disable to work on 24.05
#     plugins = {
#       smart-enter = ../config/smart-enter.yazi;
#     };
    keymap = {
      manager.prepend_keymap = [
        {on = "<Enter>"; run = "plugin --sync smart-enter"; desc = "Enter the child directory, or open the file";}
        {on = "<Delete>"; run = "remove";}
        {on = "<S-Delete>"; run = "remove --permanently";}
        {on = "y"; run = [''yank'' ''shell 'for path in "$@"; do echo "file://$path"; done | wl-copy -t text/uri-list' --confirm''];}
      ];
    };
  };

  programs.zoxide = {
    enable = true;
    enableBashIntegration = true;
    enableZshIntegration = true;
  };
}
