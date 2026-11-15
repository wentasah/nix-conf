# Development environment for the Genode OS framework
# (https://genode.org/)

# On NixOS, you need to add "services.envfs.enable = true;" to your
# configuration as some scripts have #!/usr/bin/... shebangs.

{ pkgs ? import <nixpkgs> {} }:
with pkgs;

mkShell {
  packages = [
    (callPackage ./genode-toolchain.nix { })

    expect
    rpcsvc-proto

    SDL2
    pkg-config
  ];
  CROSS_DEV_PREFIX = "genode-x86-";
  HOST_INC_DIR = "${glibc.dev}/include ${linuxHeaders}/include ${SDL2.dev}/include";
}
