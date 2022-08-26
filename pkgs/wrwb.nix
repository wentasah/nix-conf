# Environment for running WindRiver Workbench via Nix
{pkgs ? import <nixpkgs> {}}:
with pkgs; (buildFHSUserEnvBubblewrap {
  name = "wrwb";
  targetPkgs = pkgs: (with pkgs; [
    bash # lot of scripts has /bin/bash shebang
  ]);
  multiPkgs = pkgs: (with pkgs; [
    glib
    gtk3
    xorg.libXtst
    zlib
  ]);
  #runScript = "sh -x /opt/WindRiver/workbench-4/startWorkbench.sh"; # runs wrwb on background :-(
  runScript = "/opt/WindRiver/workbench-4/eclipse/x86_64-linux2/wrwb";
})
