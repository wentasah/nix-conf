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
  home.activation = {
    emacsClientSymlinks = lib.hm.dag.entryAfter ["writeBoundary"] "run ln -sf $VERBOSE_ARG emacsclient-tty $HOME/bin/ecc";
  };
  services.emacs = {
    enable = true;
    socketActivation.enable = true;
  };
  home.packages = with pkgs; [
    parinfer-rust-emacs
  ];
  programs.emacs = {
    enable = true;
    extraConfig = ''
      (setq parinfer-rust-library "${pkgs.parinfer-rust-emacs}/lib/libparinfer_rust.so")
    '';
    # # Not used since switch to straight
    # extraPackages = epkgs: with epkgs; [ edit-server magit forge nix-mode direnv vterm pod-mode ];
    package = let
      emacs = pkgs.emacs.override { withPgtk = true; };
      emacsPackages = pkgs.emacsPackagesFor emacs;
      # Override selected unstable (i.e. Melpa) packages with stable
      # version, either from MelpaStable or Elpa.
      stableOverrides = self: super: {
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
          magit-section
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
          transient
          transpose-frame
          treemacs
          unfill
          vertico
          visual-fill-column
          web-mode
          wgrep
          which-key
          window-purpose
          yafolding
          yaml-mode
          yasnippet-snippets
          zoom
          zoxide
        ;

        inherit (self.elpaPackages)
          auto-header
          cape
          dts-mode
          eglot
          electric-spacing
          jinx
          orgalist
          use-package
        ;
      };
      emacsWithPackages = (emacsPackages.overrideScope stableOverrides).emacsWithPackages;
    in
      emacsWithPackages (epkgs: (with epkgs; [
        academic-phrases
        adoc-mode
        all-the-icons
        apache-mode
        auctex-latexmk
        # auto-header # disappeared from emacs-overlay <2025-08-01 Fri>
        auto-highlight-symbol
        bats-mode
        bitbake
        cape
        ccls
        chatgpt-shell
        circe
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
        crdt
        csharp-mode
        csv-mode
        dash
        deadgrep
        diff-hl
        dired-rsync
        dirvish
        docbook
        dockerfile-mode
        doom-themes
        dpkg-dev-el
        dtrt-indent
        dts-mode
        easy-hugo
        edit-indirect
        edit-server
        eglot
        eglot-jl
        electric-ospl
        electric-spacing
        embark-consult
        envrc
        ethan-wspace
        filladapt
        flycheck-julia
        flycheck-package
        flycheck-plantuml
        flycheck-rust
        flymake-ruff
        flyspell-correct
        forge
        free-keys
        ggtags
        git-blamed
        git-link
        github-review
        glsl-mode
        gnome-c-style
        gnuplot-mode
        go-dlv
        go-mode
        google-c-style
        gptel
        graphviz-dot-mode
        guess-language
        haskell-mode
        highlight-doxygen
        hl-sentence
        imenu-list
        impatient-mode
        indent-bars
        jinja2-mode
        jinx
        jq-mode
        json-mode
        json-reformat
        julia-repl
        julia-repl
        julia-snail
        julia-ts-mode
        just-mode
        kdl-mode
        keycast
        kkp
        langtool
        ligature
        lorem-ipsum
        lsp-julia
        lsp-mode
        lsp-treemacs
        lsp-ui
        macrostep
        magit
        magit-annex
        magit-todos
        marginalia
        markdown-mode
        markdown-toc
        markdown-ts-mode
        mastodon
        md-readme
        memory-usage
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
        org-contrib
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
        parinfer-rust-mode
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
        qml-mode
        rainbow-mode
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
        treesit-grammars.with-all-grammars
        txl
        typescript-mode
        typst-preview
        udev-mode
        uncrustify-mode
        undo-tree
        unfill
        uniline
        use-package
        vala-mode
        vertico
        visual-fill-column
        vterm
        vundo
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
      ]) ++ [
        pkgs.notmuch   # From main packages set
      ]);
  };
}
