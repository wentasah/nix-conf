{ config, pkgs, lib, ... }:
# Basic home manager configuration common to all my systems. Mostly
# CLI utilities.
{
  home.packages = with pkgs; [
    (hiPrio parallel) # Prefer this over parallel from moreutils
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
    btop
    cachix
    ccls
    cloc
    cmake-language-server
    colmena
    colordiff
    csv2latex
    csvtool
    d2
    daemontools
    devenv
    dua
    entr
    exa
    fd
    ffmpeg
    #gdb # we use gdb provided by nixseparatedebuginfod module
    gcalcli
    gh
    git-machete
    gitAndTools.delta
    gitAndTools.git-lfs
    gitAndTools.git-subtrac
    gitAndTools.tig
    gitbatch
    gitui
    global
    gnumake
    gnupg
    gpg-tui
    graphviz
    help2man
    htop
    hunspellDicts.cs_CZ
    hunspellDicts.en_US
    hyperfine
    imagemagick
    jo
    jq
    libxml2 # for xmllint
    ltrace
    #mailutils # broken https://github.com/NixOS/nixpkgs/issues/223967
    man-pages-posix
    mc
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
    nix-output-monitor
    nix-prefetch
    nix-prefetch-scripts
    nix-template
    nix-tree
    nixfmt
    nixos-generators
    nixos-shell
    nixpkgs-fmt
    nixpkgs-review
    nixpkgs-update
    nurl
    nvd
    odt2txt
    oil
    p7zip
    pandoc
    pdf2svg
    pdfgrep
    pdftk
    pkg-config
    poppler_utils
    psmisc                      # killall, fuser, ...
    pv
    ranger
    redo-apenwarr
    restic
    ripgrep
    rnix-lsp
    rsync
    sd
    sequoia
    shdw
    shellcheck
    socat
    sops
    sqlite-interactive
    sshfs
    sshuttle
    tmux
    trace-cmd
    (tree-sitter.withPlugins (_: tree-sitter.allGrammars))
    uncrustify
    unzip
    valgrind
    websocat
    yamllint
    yq
    zip
    zsh-completions
    zsh-syntax-highlighting

    rustup
    # rustc cargo rls clippy
    # rust-analyzer # already in rustup
    cargo-edit cargo-expand
  ];

  home.file = {
    ".config/bat/config".text = ''
        --theme=gruvbox-light
    '';
    "bin/ec" = {
      executable = true;
      text = ''
        #!${pkgs.runtimeShell}
        if [ -n "''${DISPLAY}''${WAYLAND_DISPLAY}" ]; then
            args="--no-wait"
            [ -z "$1" ] && args="$args --create-frame"
        else
                args="-t"
        fi
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
    enableAutosuggestions = true;
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
      l     = "exa -la --group --header";
      lg    = "exa -la --group --header --git";
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
      # Make tramp work (https://www.gnu.org/software/emacs/manual/html_node/tramp/Frequently-Asked-Questions.html)
      [[ $TERM == "dumb" ]] && unsetopt zle && PS1='$ ' && return

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

      # Restore Alt-L behaviour overridden by Oh-My-Zsh (https://github.com/ohmyzsh/ohmyzsh/issues/5071)
      bindkey '^[l' down-case-word

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

      if test -n "$KITTY_INSTALLATION_DIR"; then
          export KITTY_SHELL_INTEGRATION="enabled"
          autoload -Uz -- "$KITTY_INSTALLATION_DIR"/shell-integration/zsh/kitty-integration
          kitty-integration
          unfunction kitty-integration
      fi

      source ${../pkgs/zsh-config/nix-direnv}

      # Setup ROS 2 auto completion for nix-direnv environments
      eval "$(${pkgs.python3Packages.argcomplete}/bin/register-python-argcomplete ros2)"
      eval "$(${pkgs.python3Packages.argcomplete}/bin/register-python-argcomplete colcon)"

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
        #pkgs.emacs
        pkgs.emacs-unstable
        #pkgs.emacsGit
          .override {
            # withGTK2 = false;
            # withGTK3 = false;
            # Xaw3d = pkgs.xorg.libXaw3d;
            # # lucid -> lucid
            withPgtk = true;
          }
      ).overrideAttrs(old: {
        #dontStrip = true;
        separateDebugInfo = true;
        passthru = old.passthru // {
          withTreeSitter = true;
        };
      }))).emacsWithPackages;
    in
      emacsWithPackages (epkgs: (with epkgs.melpaStablePackages; [
        all-the-icons
        forge
        magit
        pdf-tools
      ]) ++ (with epkgs.melpaPackages; [
        direnv
        julia-mode # for ikiwiki-org-plugin in my blog
        nix-mode
        vterm
      ]) ++ (with epkgs.elpaPackages; [
        jinx
      ]) ++ (if epkgs.manualPackages ? treesit-grammars then [
        epkgs.manualPackages.treesit-grammars.with-all-grammars
      ] else []) ++[
        pkgs.notmuch   # From main packages set
      ]);
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

  programs.nnn = {
    enable = true;
    extraPackages = with pkgs; [
      ffmpegthumbnailer
      mediainfo
      mpv
      nsxiv
      zathura
    ];
    plugins = {
      src = pkgs.nnn.src  + "/plugins";
      mappings = {
        i = "imgview";
        n = "nmount";
        p = "preview-tui";
      };
    };
  };
}
