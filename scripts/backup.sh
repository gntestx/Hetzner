#!/usr/bin/env bash
set -Eeuo pipefail
cd "$(dirname "$0")/.."

mkdir -p backups
stamp="$(date +%Y%m%d-%H%M%S)"
output="backups/app-${stamp}.db"

if docker compose exec -T app sh -c 'command -v sqlite3 >/dev/null 2>&1'; then
  docker compose exec -T app sqlite3 /data/app.db '.backup /tmp/app-backup.db'
  docker compose cp app:/tmp/app-backup.db "$output"
  docker compose exec -T app rm -f /tmp/app-backup.db
else
  echo "sqlite3 saknas i appcontainern. Stoppar appen för en konsekvent filbackup."
  docker compose stop app
  trap 'docker compose start app >/dev/null' EXIT
  volume="$(docker volume ls --format '{{.Name}}' | grep '_app_data$' | head -n1)"
  test -n "$volume"
  docker run --rm -v "$volume:/data:ro" -v "$PWD/backups:/backup" alpine cp /data/app.db "/backup/$(basename "$output")"
  docker compose start app
  trap - EXIT
fi

gzip "$output"
echo "Backup skapad: ${output}.gz"
