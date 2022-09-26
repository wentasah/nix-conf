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
    cachix
    ccls
    cloc
    colordiff
    csv2latex
    csvtool
    daemontools
    dua
    entr
    exa
    fd
    ffmpeg
    gdb
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
    help2man
    htop
    hunspellDicts.cs_CZ
    hunspellDicts.en_US
    imagemagick
    jq
    libxml2 # for xmllint
    ltrace
    mailutils
    man-pages-posix
    mc
    meson
    ministat
    moreutils
    mosh
    mtr
    ncdu
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
    nvd
    odt2txt
    oil
    p7zip
    pandoc
    pdf2svg
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
    sequoia
    shellcheck
    socat
    sops
    sqlite-interactive
    sshfs
    sshuttle
    tmux
    trace-cmd
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
    rust-analyzer cargo-edit
  ];

  home.file = {
    ".config/bat/config".text = ''
        --theme=gruvbox-light
    '';
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
  };

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

}
