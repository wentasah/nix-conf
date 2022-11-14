{ config, pkgs, ... }:
{
  home.sessionPath = [
    "$HOME/go/bin"
  ];

  programs.go.enable = true;

  home.packages = with pkgs; [
    gopls
    delve
  ];
}

# Local Variables:
# compile-command: "home-manager switch"
# End:
