#!/usr/bin/env bash
# Cinnamon desktop tweaks: light theme and panel width.
# Fractional display scaling (150%) is NOT included here — Cinnamon's
# fractional scaling is a manual toggle in Display Settings (see README).
set -euo pipefail

echo "==> Setting light theme (Mint-Y)"
gsettings set org.cinnamon.desktop.interface gtk-theme "Mint-Y"
gsettings set org.cinnamon.theme name "Mint-Y"
gsettings set org.cinnamon.desktop.wm.preferences theme "Mint-Y"
gsettings set org.cinnamon.desktop.interface icon-theme "Mint-Y"

echo "==> Setting panel height to 40px"
gsettings set org.cinnamon panels-height "['1:40']"

echo "==> Done. Log out/in if the panel doesn't refresh immediately."
