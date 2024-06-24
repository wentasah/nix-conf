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

- Allow accessing SSH remote stores (e.g. for using remote builders)
  on non-NixOS distribution (e.g. Debian):

  ```sh
  echo 'SetEnv PATH=/nix/var/nix/profiles/default/bin:/usr/bin:/bin:/usr/sbin:/sbin' > /etc/ssh/sshd_config.d/nix-path.conf
  ```

  Check whether it works by:

  ```sh
  nix store ping --store ssh://host
  ```

- Update home-manager configuration via a Flake:

  ```sh
  home-manager switch --flake ~/nix/conf#ritchie
  ```
