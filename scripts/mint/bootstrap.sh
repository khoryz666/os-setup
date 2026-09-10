#!/usr/bin/env bash
# Run on a fresh Linux Mint install.
# Updates the system, then installs: Nix, git, SSH key for GitHub, git identity
# config, fresh IDE, podman, and the desktop apps (Firefox, Chrome, Nuclear,
# Obsidian, Discord) — apt first, Flatpak as fallback when apt doesn't have it.
set -euo pipefail

# --- apt-only-or-flatpak-fallback installer ---
# Tries a plain `apt install` (Mint's default repos only — no extra repos/keys/.deb).
# Falls back to Flatpak (Flathub) if the package isn't available via apt.
install_pkg() {
    local label="$1" apt_name="$2" flatpak_id="$3"
    echo "==> Installing $label"
    if apt-cache show "$apt_name" >/dev/null 2>&1; then
        sudo apt install -y "$apt_name"
        return 0
    fi
    echo "    '$apt_name' not in apt repos, falling back to Flatpak: $flatpak_id"
    if ! command -v flatpak >/dev/null 2>&1; then
        sudo apt install -y flatpak
        flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    fi
    flatpak install -y flathub "$flatpak_id"
}

echo "==> Updating and upgrading the system"
sudo apt update && sudo apt upgrade -y

echo "==> Installing Nix (multi-user daemon install)"
if ! command -v nix >/dev/null 2>&1; then
    sh <(curl -L https://nixos.org/nix/install) --daemon
else
    echo "nix already installed, skipping"
fi

echo "==> Installing git"
sudo apt install -y git

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

# --- Desktop apps: apt first, Flatpak fallback ---
# Note: Google Chrome is not in Mint's default apt repos, and we're
# intentionally not adding Google's repo / installing a .deb, so this always
# falls through to the real Chrome Flatpak (com.google.Chrome on Flathub).
install_pkg "Firefox"  "firefox"        "org.mozilla.firefox"
install_pkg "Chrome"   "google-chrome-stable" "com.google.Chrome"
install_pkg "Nuclear"  "nuclear"        "com.nuclearplayer.Nuclear"
install_pkg "Obsidian" "obsidian"       "md.obsidian.Obsidian"
install_pkg "Discord"  "discord"        "com.discordapp.Discord"

echo "==> Done"
