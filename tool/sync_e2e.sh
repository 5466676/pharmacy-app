#!/usr/bin/env bash
# End-to-end sync test: the real server (FastAPI + PostgreSQL) and two app
# databases talking to it over HTTPS (pinned self-made certificate). Needs PostgreSQL with the `doaya` role
# (see backend/README.md) and the backend's .venv.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
PORT="${PORT:-8765}"
DB="doaya_e2e"
export PGPASSWORD="${PGPASSWORD:-doaya}"
URL="postgresql+psycopg://doaya:${PGPASSWORD}@localhost:5432/${DB}"

psql -h localhost -U doaya -d postgres -qc "DROP DATABASE IF EXISTS ${DB}" -c "CREATE DATABASE ${DB}"
cd "$ROOT/backend"
DOAYA_DATABASE_URL="$URL" .venv/bin/alembic upgrade head >/dev/null
DATA_DIR="$(mktemp -d)"
DOAYA_DATABASE_URL="$URL" DOAYA_DATA_DIR="$DATA_DIR" DOAYA_HTTP_PORT="$PORT" \
  DOAYA_DISCOVERY_PORT=0 .venv/bin/python -m app.serve >"$DATA_DIR/server.log" 2>&1 &
SERVER=$!
trap 'kill $SERVER 2>/dev/null; rm -rf "$DATA_DIR"' EXIT
for _ in $(seq 50); do curl --noproxy "*" -skf "https://localhost:${PORT}/health" >/dev/null && break; sleep 0.2; done

cd "$ROOT/apps/pharmacy"
DOAYA_SERVER_URL="https://localhost:${PORT}/" flutter test test/sync_server_e2e_test.dart
