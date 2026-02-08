user := "core"
server := "192.168.1.226"

create-secrets:
    # Postgres passwords
    sops -d secrets.yaml | yq -r '.postgres.password' | tr -d '\n' | ssh {{user}}@{{server}} 'podman secret create --ignore POSTGRES_PASSWORD -'
    sops -d secrets.yaml | yq -r '.postgres.n8n_password' | tr -d '\n' | ssh {{user}}@{{server}} 'podman secret create --ignore N8N_POSTGRESQL__PASSWORD -'
    sops -d secrets.yaml | yq -r '.postgres.immich_password' | tr -d '\n' | ssh {{user}}@{{server}} 'podman secret create --ignore IMMICH_POSTGRESQL__PASSWORD -'
    sops -d secrets.yaml | yq -r '.postgres.grafana_password' | tr -d '\n' | ssh {{user}}@{{server}} 'podman secret create --ignore GRAFANA_POSTGRESQL__PASSWORD -'
    sops -d secrets.yaml | yq -r '.postgres.paperless_password' | tr -d '\n' | ssh {{user}}@{{server}} 'podman secret create --ignore PAPERLESS_POSTGRESQL__PASSWORD -'
    sops -d secrets.yaml | yq -r '.postgres.authentik_password' | tr -d '\n' | ssh {{user}}@{{server}} 'podman secret create --ignore AUTHENTIK_POSTGRESQL__PASSWORD -'
    sops -d secrets.yaml | yq -r '.postgres.linkwarden_password' | tr -d '\n' | ssh {{user}}@{{server}} 'podman secret create --ignore LINKWARDEN_POSTGRESQL__PASSWORD -'

    # App secrets
    sops -d secrets.yaml | yq -r '.app.nextauth_secret' | tr -d '\n' | ssh {{user}}@{{server}} 'podman secret create --ignore NEXTAUTH_SECRET -'
    sops -d secrets.yaml | yq -r '.app.meili_master_key' | tr -d '\n' | ssh {{user}}@{{server}} 'podman secret create --ignore MEILI_MASTER_KEY -'
    sops -d secrets.yaml | yq -r '.app.authentik_secret_key' | tr -d '\n' | ssh {{user}}@{{server}} 'podman secret create --ignore AUTHENTIK_SECRET_KEY -'
    sops -d secrets.yaml | yq -r '.app.paperless_secret_key' | tr -d '\n' | ssh {{user}}@{{server}} 'podman secret create --ignore PAPERLESS_SECRET_KEY -'
    sops -d secrets.yaml | yq -r '.app.linkwarden_database_url' | tr -d '\n' | ssh {{user}}@{{server}} 'podman secret create --ignore LINKWARDEN_DATABASE_URL -'

    # Linkwarden OAuth (Authentik)
    sops -d secrets.yaml | yq -r '.terraform.authentik.oauth.linkwarden.client_id' | tr -d '\n' | ssh {{user}}@{{server}} 'podman secret create --ignore AUTHENTIK_CLIENT_ID -'
    sops -d secrets.yaml | yq -r '.terraform.authentik.oauth.linkwarden.client_secret' | tr -d '\n' | ssh {{user}}@{{server}} 'podman secret create --ignore AUTHENTIK_CLIENT_SECRET -'

    # API tokens
    sops -d secrets.yaml | yq -r '.app.caddy_cloudflare_dns_token' | tr -d '\n' | ssh {{user}}@{{server}} 'podman secret create --ignore CLOUDFLARE_API_TOKEN -'
    sops -d secrets.yaml | yq -r '.app.PAPERLESS_SOCIALACCOUNT_PROVIDERS' | tr -d '\n' | ssh {{user}}@{{server}} 'podman secret create --ignore PAPERLESS_SOCIALACCOUNT_PROVIDERS -'

copy-configs:
    scp -r ./quadlets/* {{user}}@{{server}}:~/.config/containers/systemd/
    ssh {{user}}@{{server}} 'systemctl --user daemon-reload'
