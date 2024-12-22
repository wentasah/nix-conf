# Environment for running wrenv.sh via Nix

# You can use this without installing by: nix-shell -E '(import ./wrenv.nix {}).env

{pkgs ? import <nixpkgs> {}}:
with pkgs; (buildFHSEnvBubblewrap {
  name = "wrenv.sh";
  runScript = "/opt/WindRiver/wrenv.sh";
  targetPkgs = pkgs: (with pkgs; [
    bash # lot of scripts has /bin/bash shebang
  ]);
  profile = ''
    export STARSHIP_PREFIX="(vxworks)"
  '';
  multiPkgs = pkgs: (with pkgs; [ glib gtk3 xorg.libXtst zlib ]);
})
