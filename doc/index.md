# My Nix notes

- Figure out why package _XXX_ is in my system configuration:

  ```sh
  nix why-depends .#nixosConfigurations.$HOST.config.system.build.toplevel .#nixosConfigurations.$HOST.pkgs.XXX
  ```

- Interactive browsing of NixOS configuration
  ([source](https://www.reddit.com/r/NixOS/comments/u6fl8j/comment/i57wc0d/)):

  Non-flake system:

      nix repl>:l <nixpkgs/nixos>

  Flake system:

      nix repl>:lf /etc/nixos
      nix repl>nixosConfigurations.<hostname>
