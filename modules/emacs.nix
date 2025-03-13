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
      emacs = pkgs.emacs.override { withPgtk = true; };
      emacsPackages = pkgs.emacsPackagesFor emacs;
      overrides = self: super: {
        inherit (self.melpaStablePackages)

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

        ;

        inherit (self.elpaPackages)

          auto-header
          cape
          dts-mode
          electric-spacing
          jinx
          orgalist
          use-package

        ;
      };
      emacsWithPackages = (emacsPackages.overrideScope overrides).emacsWithPackages;
    in
      emacsWithPackages (epkgs: (with epkgs; [
        academic-phrases
        all-the-icons
        auctex-latexmk
        auto-header
        auto-highlight-symbol
        bats-mode
        bitbake
        cape
        ccls
        chatgpt-shell
        clang-format
        color-identifiers-mode
        command-log-mode
        consult
        consult-dir
        consult-flycheck
        consult-ls-git
        consult-lsp
        consult-notmuch
        corfu
        csharp-mode
        dash
        diff-hl
        dired-rsync
        dirvish
        doom-themes
        dtrt-indent
        dts-mode
        edit-indirect
        edit-server
        electric-ospl
        electric-spacing
        embark-consult
        envrc
        ethan-wspace
        flycheck-package
        flycheck-rust
        flymake-ruff
        flyspell-correct
        forge
        free-keys
        ggtags
        gptel
        guess-language
        haskell-mode
        hl-sentence
        imenu-list
        jinx
        json-mode
        json-reformat
        julia-snail
        julia-ts-mode
        just-mode
        kkp
        lorem-ipsum
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
        md-readme
        meson-mode
        mo-git-blame
        modus-themes
        most-used-words
        multiple-cursors
        my-repo-pins
        ninja-mode
        nix-mode
        nix-update
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
        org-msg
        org-present
        org-ql
        org-super-agenda
        org-tree-slide
        orgalist
        ox-gfm
        ox-slack
        paredit
        paredit-everywhere
        paredit-menu
        pdf-tools
        php-mode
        plantuml-mode
        poly-markdown
        polymode
        projectile
        protobuf-mode
        python-black
        python-docstring
        python-insert-docstring
        python-pytest
        ripgrep
        robot-mode
        ruff-format
        rust-mode
        (rustic.overrideAttrs ({ packageRequires ? [], ...}: { packageRequires = packageRequires ++ [ flycheck ]; }))
        simple-httpd
        smartparens
        smartrep
        smog
        spdx
        strace-mode
        string-edit-at-point
        symbol-overlay
        systemd
        tabbar
        tommyh-theme
        transpose-frame
        tree-mode
        treemacs
        txl
        typo
        udev-mode
        uncrustify-mode
        unfill
        uniline
        use-package
        vala-mode
        vertico
        visual-fill-column
        vterm
        web-mode
        wgrep
        which-key
        window-purpose
        yafolding
        yaml-mode
        yasnippet
        yasnippet-snippets
        zig-mode
        zoom
        zoxide
      ]) ++ (if epkgs.manualPackages ? treesit-grammars then [
        epkgs.manualPackages.treesit-grammars.with-all-grammars
      ] else []) ++[
        pkgs.notmuch   # From main packages set
      ]);
  };
}
