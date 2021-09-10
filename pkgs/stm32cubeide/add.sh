#!/bin/sh

set -x

nix_store_path="$(nix-store --add en.st-stm32cubeide_1.5.1_9029_20201210_1234_amd64.sh.zip)"
nix-store --add-root ./nix-gcroot --indirect --realise "$nix_store_path"
