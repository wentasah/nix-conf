{ pkgs ? import <nixpkgs> {} }:
with pkgs;
callPackage ./stm32cubeide.nix {}
