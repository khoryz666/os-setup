#!/usr/bin/env bash
# Run inside the WSL Ubuntu distro after first boot.
# Installs: Nix, git, SSH key for GitHub, git identity config, fresh IDE, podman.
set -euo pipefail

echo "==> Updating apt"
sudo apt update

echo "==> Installing git"
sudo apt install -y git

echo "==> Installing Nix (multi-user daemon install)"
if ! command -v nix >/dev/null 2>&1; then
    sh <(curl -L https://nixos.org/nix/install) --daemon
else
    echo "nix already installed, skipping"
fi

echo "==> SSH key for GitHub"
KEY="$HOME/.ssh/id_ed25519"
read -rp "Email for SSH key / git config: " GIT_EMAIL
if [ ! -f "$KEY" ]; then
    ssh-keygen -t ed25519 -C "$GIT_EMAIL" -f "$KEY" -N ""
else
    echo "SSH key already exists at $KEY, skipping generation"
fi

eval "$(ssh-agent -s)"
ssh-add "$KEY"

echo
echo "Add the following public key to https://github.com/settings/keys :"
echo "----------------------------------------------------------------"
cat "$KEY.pub"
echo "----------------------------------------------------------------"
read -rp "Press Enter once the key has been added to GitHub..."

echo "==> git config"
read -rp "git config user.name: " GIT_NAME
git config --global user.name "$GIT_NAME"
git config --global user.email "$GIT_EMAIL"
git config --global init.defaultBranch main

echo "==> Verifying GitHub SSH auth"
ssh -T git@github.com || true

echo "==> Installing fresh IDE"
curl -fsSL https://raw.githubusercontent.com/sinelaw/fresh/refs/heads/master/scripts/install.sh | sh

echo "==> Installing podman"
sudo apt install -y podman

echo "==> Done"
