!/usr/bin/env bash

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
openssl rand -hex 16 | podman secret create --ignore POSTGRES_PASSWORD -

# Authentik
openssl rand -hex 32 | podman secret create --ignore AUTHENTIK_SECRET_KEY -
openssl rand -hex 16 | podman secret create --ignore AUTHENTIK_POSTGRESQL__PASSWORD -

# Caddy (prompted)
read -r -s -p "Enter Caddy Clouflare DNS API token: " TOKEN
echo
printf '%s' "$TOKEN" | podman secret create --ignore CLOUDFLARE_API_TOKEN -
unset TOKEN

# Linkwarden
openssl rand -hex 32 | podman secret create --ignore NEXTAUTH_SECRET -
openssl rand -hex 32 | podman secret create --ignore MEILI_MASTER_KEY -

DB_PASSWORD="$(openssl rand -hex 16)"

printf '%s' "$DB_PASSWORD" |
  podman secret create --ignore LINKWARDEN_POSTGRESQL__PASSWORD -

printf 'postgresql://linkwarden:%s@postgres:5432/linkwarden' "$DB_PASSWORD" |
  podman secret create --ignore LINKWARDEN_DATABASE_URL -

unset DB_PASSWORD
