#!/usr/bin/env bash
# Opal bootstrap (runs on the host before the pipeline, see config.toml).
#
# Jobs run in a plain container that gets the host's /nix mounted and
# talks to the host Nix daemon. This script:
# - builds the tools needed by the jobs (with the host Nix) and puts
#   them into PATH via the generated env file,
# - creates symlinks in .opal/mounts/ to host directories mounted into
#   the containers (opal mounts don't expand ~).

set -euo pipefail
cd "$(dirname "$0")"
repo=$(git rev-parse --show-toplevel)

nix build --out-link tools --impure --expr "
  let pkgs = (builtins.getFlake \"git+file://$repo\").inputs.nixpkgs.legacyPackages.\${builtins.currentSystem};
  in pkgs.buildEnv {
    name = \"nix-ci-tools\";
    paths = with pkgs; [ attic-client bashInteractive cacert coreutils findutils gitMinimal gnugrep gnused openssh python3 ];
  }"
tools=$(readlink -f tools)
host_nix_bin=$(dirname "$(readlink -f "$(command -v nix)")")

# HOME of the jobs (/opal/home), owned by the host user and persistent
# across runs (e.g. ~/.cache/nix). Pre-create the mount points of the
# nested mounts below, otherwise docker would create them as root.
mkdir -p home/.ssh home/.config/attic home/.config/nix home/nix/nixpkgs

mkdir -p mounts empty
link() {  # link NAME HOST_PATH - fall back to an empty directory
    if [[ -e $2 ]]; then ln -sfn "$2" "mounts/$1"; else ln -sfn ../empty "mounts/$1"; fi
}
link nixpkgs     "$HOME/nix/nixpkgs"
link ssh         "$HOME/.ssh"
link attic       "${XDG_CONFIG_HOME:-$HOME/.config}/attic"
link nix-config  "${XDG_CONFIG_HOME:-$HOME/.config}/nix"

# Use explicit ssh options: the home directory from /etc/passwd isn't
# available in the container.
ssh_cmd="ssh -o UserKnownHostsFile=/opal/home/.ssh/known_hosts"
for key in id_ed25519 id_ecdsa id_rsa; do
    if [[ -f $HOME/.ssh/$key ]]; then ssh_cmd+=" -i /opal/home/.ssh/$key"; fi
done

cat > bootstrap.env <<EOT
PATH=$tools/bin:$host_nix_bin:/usr/bin:/bin
HOME=/opal/home
NIX_REMOTE=daemon
NIX_SSL_CERT_FILE=$tools/etc/ssl/certs/ca-bundle.crt
SSL_CERT_FILE=$tools/etc/ssl/certs/ca-bundle.crt
GIT_SSL_CAINFO=$tools/etc/ssl/certs/ca-bundle.crt
GIT_SSH_COMMAND=$ssh_cmd
EOT
