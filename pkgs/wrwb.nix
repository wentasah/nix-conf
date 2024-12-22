# Environment for running WindRiver Workbench via Nix

# You can use this without installing by: nix-shell -E '(import ./wrwb.nix {}).env

{pkgs ? import <nixpkgs> {}}:
with pkgs; (buildFHSEnvBubblewrap {
  name = "wrwb";
  targetPkgs = pkgs: (with pkgs; [
    bash # lot of scripts has /bin/bash shebang
    webkitgtk                   # help view
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
