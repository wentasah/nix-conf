{ pkgs, ...}:
{
  home.packages = with pkgs; [
    qtcreator
    qt6.full
  ];
}
