# Doaya server

FastAPI + PostgreSQL. It runs on the pharmacy's own computer and the pharmacy's devices sync with it over the local network (see `docs/PROGRESS.md`, Phase 2).

## Development
```bash
cd backend
python3 -m venv .venv && .venv/bin/pip install -e ".[dev]"
# a PostgreSQL with a `doaya` role and a `doaya_test` database:
#   CREATE ROLE doaya LOGIN PASSWORD 'doaya' CREATEDB;  CREATE DATABASE doaya_test OWNER doaya;
.venv/bin/pytest                    # tests run against the real PostgreSQL
.venv/bin/ruff check . && .venv/bin/ruff format --check .
.venv/bin/python -m app.serve       # HTTPS on :8000 + Wi-Fi discovery + daily backups
.venv/bin/python -m app.cli server-code   # the code devices show when they link
```

Settings come from `DOAYA_*` environment variables or `backend/.env` (see `.env.example`).

## Encryption
Traffic on the Wi-Fi is HTTPS. On first start the server makes its own certificate
(`data/server.crt`, `data/server.key`, EC P-256, 20 years). There is no certificate
authority on a pharmacy LAN, so the app pins the certificate's SHA-256 on first link
(discovery announces it) and refuses any other one afterwards. `server-code` prints the
short form (e.g. `AB12-CD34`) that the app shows, to compare by eye. Deleting the two
files makes a new certificate, and every device must then be linked again.
