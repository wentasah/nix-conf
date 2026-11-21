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

# opal runs this via `sh -lc`, whose login profile may reset PATH (e.g.
# Debian's /etc/profile), so look for nix in the usual locations too.
if ! command -v nix > /dev/null; then
    for dir in "$HOME/.nix-profile/bin" "${XDG_STATE_HOME:-$HOME/.local/state}/nix/profile/bin" \
               "/etc/profiles/per-user/$USER/bin" /nix/var/nix/profiles/default/bin /run/current-system/sw/bin; do
        if [[ -x $dir/nix ]]; then
            PATH=$dir:$PATH
            break
        fi
    done
fi
command -v nix > /dev/null || { echo "bootstrap.sh: nix not found (PATH=$PATH)" >&2; exit 127; }

repo=$(git rev-parse --show-toplevel)

nix build --out-link tools --impure --expr "
  let pkgs = (builtins.getFlake \"git+file://$repo\").inputs.nixpkgs.legacyPackages.\${builtins.currentSystem};
  in pkgs.buildEnv {
    name = \"nix-ci-tools\";
    paths = with pkgs; [ attic-client bashInteractive cacert coreutils dix findutils gitMinimal gnugrep gnused jq matrix-commander-rs openssh python3 ];
  }"
tools=$(readlink -f tools)
host_nix_bin=$(dirname "$(readlink -f "$(command -v nix)")")

# HOME of the jobs (/opal/home), owned by the host user and persistent
# across runs (e.g. ~/.cache/nix). Pre-create the mount points of the
# nested mounts below, otherwise docker would create them as root.
mkdir -p home/.ssh home/.config/attic home/.config/nix home/nix/nixpkgs \
         home/.local/share/matrix-commander-rs

mkdir -p mounts empty
link() {  # link NAME HOST_PATH - fall back to an empty directory
    if [[ -e $2 ]]; then ln -sfn "$2" "mounts/$1"; else ln -sfn ../empty "mounts/$1"; fi
}
link nixpkgs     "$HOME/nix/nixpkgs"
link ssh         "$HOME/.ssh"
link attic       "${XDG_CONFIG_HOME:-$HOME/.config}/attic"
link nix-config  "${XDG_CONFIG_HOME:-$HOME/.config}/nix"
link matrix      "${XDG_DATA_HOME:-$HOME/.local/share}/matrix-commander-rs"

# GC roots of build results (direct symlinks to the store, so they
# work regardless of where the directory is mounted). Used to diff
# build results against the previous run.
gcroots=/nix/var/nix/gcroots/per-user/$USER/nix-ci
mkdir -p "$gcroots" || echo "bootstrap.sh: warning: cannot create $gcroots" >&2
link gcroots     "$gcroots"

# Use explicit ssh options: the home directory from /etc/passwd isn't
# available in the container.
ssh_cmd="ssh -o UserKnownHostsFile=/opal/home/.ssh/known_hosts"
for key in wsh-nix-bot id_ed25519 id_ecdsa id_rsa; do
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
NIX_CI_GCROOTS=/opal/gcroots
EOT
