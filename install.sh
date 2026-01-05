#!/usr/bin/env bash

set -euo pipefail

packages=(
  stow
)

echo "Layering packages with rpm-ostree..."
sudo rpm-ostree install "${packages[@]}" --apply-live >/dev/null || true

# --------------------------------------------------
# Podman secrets
# --------------------------------------------------

# PostgreSQL
openssl rand -base64 36 | tr -d '\n' | podman secret create --ignore POSTGRES_PASSWORD -
openssl rand -base64 36 | tr -d '\n' | podman secret create --ignore AUTHENTIK_POSTGRESQL__PASSWORD -
openssl rand -base64 36 | tr -d '\n' | podman secret create --ignore LINKWARDEN_POSTGRESQL__PASSWORD -

# Authentik
openssl rand -base64 60 | tr -d '\n' | podman secret create --ignore AUTHENTIK_SECRET_KEY -

# Caddy (prompted)
read -r -s -p "Enter Caddy Clouflare DNS API token: " TOKEN
echo
printf '%s' "$TOKEN" | podman secret create --ignore CLOUDFLARE_API_TOKEN -
unset TOKEN
