#!/bin/sh
# Start EdgeEver on Railway.
# - Railway volumes mount as root, while EdgeEver runs as the non-root "bun"
#   user (UID 1000), so give /data to that user before dropping privileges.
# - Refuse to start without a login: an open instance would expose every note.
# - Any unexpected exit of the server is non-zero, so Railway's ON_FAILURE
#   restart policy brings it back.
set -eu

DATA_DIR="${EDGE_EVER_DATA_DIR:-/data}"

if [ -z "${EDGE_EVER_AUTH_PASSWORD:-}" ] && [ -z "${EDGE_EVER_AUTH_PASSWORD_HASH:-}" ] && [ -z "${EDGE_EVER_AUTH_PASSWORD_FILE:-}" ]; then
  echo "[railway] EDGE_EVER_AUTH_PASSWORD is empty. Set it (the template generates one) and redeploy." >&2
  exit 1
fi
if [ "${EDGE_EVER_ALLOW_UNAUTHENTICATED:-}" = "true" ]; then
  echo "[railway] EDGE_EVER_ALLOW_UNAUTHENTICATED=true would expose every note on a public URL; refusing to start." >&2
  exit 1
fi

mkdir -p "$DATA_DIR"
if [ "$(id -u)" = "0" ]; then
  if [ "$(stat -c %u "$DATA_DIR")" != "1000" ] || [ -n "$(find "$DATA_DIR" -mindepth 1 ! -user 1000 -print -quit 2>/dev/null)" ]; then
    chown -R 1000:1000 "$DATA_DIR"
  fi
  exec setpriv --reuid=1000 --regid=1000 --init-groups --inh-caps=-all \
    env HOME=/home/bun bun --preload /app/scripts/railway-proxy.mjs /app/scripts/self-hosted-server.js
fi

exec bun --preload /app/scripts/railway-proxy.mjs /app/scripts/self-hosted-server.js
