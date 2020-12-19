/*
This is a nix expression to build Emacs and some Emacs packages I like
from source on any distribution where Nix is installed. This will install
all the dependencies from the nixpkgs repository and build the binary files
without interfering with the host distribution.

To build the project, type the following from the current directory:

$ nix-build emacs.nix

To run the newly compiled executable:

$ ./result/bin/emacs
*/
{ pkgs ? import <nixpkgs> {} }:



let
  myEmacs = pkgs.emacs.override {
    withGTK2 = false;
    withGTK3 = false;
    Xaw3d = pkgs.xorg.libXaw3d;
    # lucid -> lucid
  };

  emacsWithPackages = (pkgs.emacsPackagesFor myEmacs).emacsWithPackages;
in
  emacsWithPackages (epkgs: (with epkgs.melpaStablePackages; [
    magit          # ; Integrate git <C-x g>
    helm
  ]) ++ (with epkgs.melpaPackages; [
    smartparens
    nix-mode
  ]) ++ (with epkgs.elpaPackages; [
    auctex         # ; LaTeX mode
  ]) ++ [
    pkgs.notmuch   # From main packages set
  ])
