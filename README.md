# Hetzner_info

Startpaket för att köra en containeriserad Blazor-webbapp på Hetzner Cloud med Docker Compose, Caddy, automatiska TLS-certifikat, tenant-subdomäner och SQLite på persistent volym.

## Snabbstart

```bash
cp .env.example .env
chmod +x scripts/*.sh
docker compose pull
docker compose up -d
```

Uppdatera först `.env` och `Caddyfile` med din image och domän.

## DNS

```text
A   @   <SERVERNS_IPV4>
A   *   <SERVERNS_IPV4>
```

## Deployment

```bash
./scripts/deploy.sh
```

## Backup

```bash
./scripts/backup.sh
```

## Återställning

```bash
./scripts/restore.sh backups/app-YYYYMMDD-HHMMSS.db
```

Se [docs/server-setup.md](docs/server-setup.md) för komplett installation.
