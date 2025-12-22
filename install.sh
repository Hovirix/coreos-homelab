#!/usr/bin/env bash

set -euo pipefail

packages=(
  stow
  cockpit-system
  cockpit-ostree
  cockpit-storaged
  cockpit-networkmanager
)

echo "Layering packages with rpm-ostree..."
sudo rpm-ostree install "${packages[@]}" --apply-live >/dev/null || true

# --------------------------------------------------
# Podman secrets (to be implemented)
# --------------------------------------------------
