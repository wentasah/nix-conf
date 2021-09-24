{ config, pkgs, ... }:
{
  home.sessionPath = [
    "$HOME/go/bin"
  ];

  programs.go.enable = true;
  programs.go.package = pkgs.go_1_17;

  home.packages = with pkgs; [
    gopls
  ];
}
