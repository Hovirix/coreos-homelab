#!/usr/bin/env bash

set -euo pipefail

# ==================================================
# PostgreSQL
# ==================================================

openssl rand -hex 16 | podman secret create --ignore POSTGRES_PASSWORD -

# ==================================================
# n8n
# ==================================================

openssl rand -hex 16 | podman secret create --ignore N8N_POSTGRESQL__PASSWORD -

# ==================================================
# Authentik (identity provider)
# ==================================================

openssl rand -hex 32 | podman secret create --ignore AUTHENTIK_SECRET_KEY -
openssl rand -hex 16 | podman secret create --ignore AUTHENTIK_POSTGRESQL__PASSWORD -

# ==================================================
# Cloudflare API (Caddy DNS challenge) - PROMPTED
# ==================================================

read -r -s -p "Enter Caddy Cloudflare DNS API token: " TOKEN
echo
printf '%s' "$TOKEN" | podman secret create --ignore CLOUDFLARE_API_TOKEN -
unset TOKEN

# ==================================================
# Linkwarden
# ==================================================

openssl rand -hex 32 | podman secret create --ignore NEXTAUTH_SECRET -
openssl rand -hex 32 | podman secret create --ignore MEILI_MASTER_KEY -

DB_PASSWORD="$(openssl rand -hex 16)"

printf '%s' "$DB_PASSWORD" |
  podman secret create --ignore LINKWARDEN_POSTGRESQL__PASSWORD -

printf 'postgresql://linkwarden:%s@postgres:5432/linkwarden' "$DB_PASSWORD" |
  podman secret create --ignore LINKWARDEN_DATABASE_URL -

unset DB_PASSWORD

# ==================================================
# Immich
# ==================================================

openssl rand -hex 16 | podman secret create --ignore IMMICH_POSTGRESQL__PASSWORD -

# ==================================================
# Paperless-ngx
# ==================================================

openssl rand -hex 32 | podman secret create --ignore PAPERLESS_SECRET_KEY -
openssl rand -hex 16 | podman secret create --ignore PAPERLESS_POSTGRESQL__PASSWORD -

# ==================================================
# Copy quadlet files to systemd directory
# ==================================================

SYSTEMD_DIR="$HOME/.config/containers/systemd"
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Creating systemd directory structure..."
mkdir -p "$SYSTEMD_DIR"

echo "Removing old symlinks (from previous stow setup)..."
find "$SYSTEMD_DIR" -type l -delete

echo "Copying quadlet files..."

echo "  - Networks..."
cp -f "$PROJECT_DIR/networks"/* "$SYSTEMD_DIR/"

echo "  - Service files..."
for service in authentik caddy immich linkwarden n8n paperless-ngx postgres traefik valkey vaultwarden; do
  if [ -d "$PROJECT_DIR/$service" ]; then
    echo "    * $service"
    find "$PROJECT_DIR/$service" -maxdepth 1 -type f ! -name "*.env" -exec cp -f {} "$SYSTEMD_DIR/" \; 2>/dev/null || true
  fi
done

echo "  - PostgreSQL init directory..."
if [ -d "$PROJECT_DIR/postgres/init" ]; then
  cp -rf "$PROJECT_DIR/postgres/init" "$SYSTEMD_DIR/"
fi

echo "Files copied successfully!"
