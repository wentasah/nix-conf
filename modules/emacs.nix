{ config, pkgs, lib, ... }:
{
  home.file = {
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
  };
  services.emacs = {
    enable = true;
    socketActivation.enable = true;
  };
  programs.emacs = {
    enable = true;

    #     # Not used since switch to straight
    #     extraPackages = epkgs: with epkgs; [ edit-server magit forge nix-mode direnv vterm pod-mode ];
    extraPackages = epkgs: with epkgs; [
    ];

    package = let
      emacsWithPackages = (pkgs.emacsPackagesFor (pkgs.emacs.override { withPgtk = true; })).emacsWithPackages;
    in
      emacsWithPackages (epkgs: (with epkgs.melpaStablePackages; [
        all-the-icons
        auto-highlight-symbol
        chatgpt-shell
        color-identifiers-mode
        consult
        consult-dir
        consult-flycheck
        consult-lsp
        consult-notmuch
        corfu
        csharp-mode
        dash
        diff-hl
        dired-rsync
        dirvish
        doom-themes
        edit-indirect
        edit-server
        electric-ospl
        embark-consult
        envrc
        ethan-wspace
        flycheck-package
        flycheck-rust
        flyspell-correct
        forge
        free-keys
        ggtags
        gptel
        haskell-mode
        hl-sentence
        imenu-list
        json-mode
        json-reformat
        julia-snail
        julia-ts-mode
        just-mode
        lsp-julia
        lsp-mode
        lsp-treemacs
        lsp-ui
        macrostep
        magit
        magit-todos
        marginalia
        markdown-mode
        mastodon
        meson-mode
        modus-themes
        most-used-words
        multiple-cursors
        my-repo-pins
        nixos-options
        nixpkgs-fmt
        notmuch
        ol-notmuch
        orderless
        org-appear
        org-babel-eval-in-repl
        org-caldav
        org-mime
        org-modern
        org-ql
        org-super-agenda
        org-tree-slide
        ox-gfm
        paredit
        paredit-everywhere
        pdf-tools
        php-mode
        plantuml-mode
        poly-markdown
        polymode
        projectile
        protobuf-mode
        python-black
        python-insert-docstring
        python-pytest
        ripgrep
        robot-mode
        rust-mode
        simple-httpd
        string-edit-at-point
        symbol-overlay
        systemd
        tabbar
        transpose-frame
        treemacs
        typo
        unfill
        vertico
        visual-fill-column
        web-mode
        wgrep
        which-key
        window-purpose
        yafolding
        yaml-mode
        yasnippet
        yasnippet-snippets
        zoom
        zoxide

      ]) ++ (with epkgs.melpaPackages; [
        academic-phrases
        auctex-latexmk
        bats-mode
        bitbake
        ccls
        clang-format
        command-log-mode
        consult-ls-git
        dtrt-indent
        flymake-ruff
        kkp
        lorem-ipsum
        md-readme
        mo-git-blame
        ninja-mode
        nix-mode
        nix-update
        org-msg
        org-present
        ox-slack
        paredit-menu
        python-docstring
        ruff-format
        (rustic.overrideAttrs ({ packageRequires ? [], ...}: { packageRequires = packageRequires ++ [ flycheck ]; }))
        smartparens
        smartrep
        smog
        spdx
        strace-mode
        tommyh-theme
        tree-mode
        txl
        udev-mode
        uncrustify-mode
        uniline
        vala-mode
        vterm
        zig-mode

      ]) ++ (with epkgs.elpaPackages; [
        auto-header
        cape
        dts-mode
        electric-spacing
        guess-language
        jinx
        orgalist
        use-package

      ]) ++ (if epkgs.manualPackages ? treesit-grammars then [
        epkgs.manualPackages.treesit-grammars.with-all-grammars
      ] else []) ++[
        pkgs.notmuch   # From main packages set
      ]);
  };
}
