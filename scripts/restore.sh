#!/usr/bin/env bash
set -Eeuo pipefail
cd "$(dirname "$0")/.."

file="${1:-}"
if [[ -z "$file" || ! -f "$file" ]]; then
  echo "Användning: $0 backups/app-YYYYMMDD-HHMMSS.db[.gz]" >&2
  exit 1
fi

tmp=""
if [[ "$file" == *.gz ]]; then
  tmp="$(mktemp --suffix=.db)"
  gunzip -c "$file" > "$tmp"
  source_file="$tmp"
else
  source_file="$file"
fi
trap '[[ -n "$tmp" ]] && rm -f "$tmp"' EXIT

docker compose stop app
volume="$(docker volume ls --format '{{.Name}}' | grep '_app_data$' | head -n1)"
test -n "$volume"
docker run --rm -v "$volume:/data" -v "$(realpath "$source_file"):/restore.db:ro" alpine sh -c 'cp /restore.db /data/app.db && chown 1654:1654 /data/app.db || true'
docker compose start app

echo "Databasen återställd från: $file"
