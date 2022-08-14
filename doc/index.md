# My Nix notes

- Figure out why package _XXX_ is in my system configuration:

  ```sh
  nix why-depends .#nixosConfigurations.$HOST.config.system.build.toplevel .#nixosConfigurations.$HOST.pkgs.XXX
  ```
