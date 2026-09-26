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

## Central (internet) server
The same app also serves patients: accounts, the pharmacy directory, shelves, AI consultations → cases, and pickup orders (Phase 3).
```bash
.venv/bin/python -m app.cli create-pharmacy --name "صيدلية الشفاء" --owner-name سامر --owner-phone 0944123456 --password '...'
.venv/bin/python -m app.cli list-pharmacy <pharmacy-id> --code SH4F --city دمشق --hours "9 - 23"
.venv/bin/python -m app.cli pharmacy-key <pharmacy-id>     # → that pharmacy server's DOAYA_CENTRAL_KEY
```
On the pharmacy's own server set `DOAYA_CENTRAL_URL` and `DOAYA_CENTRAL_KEY`. It then publishes its shelf every 10 minutes, and its devices reach their cases and orders through `/central/…`.
The AI assistant uses any OpenAI-compatible server (`DOAYA_LLM_BASE_URL`, LM Studio by default). Emergency numbers: `DOAYA_EMERGENCY_AMBULANCE` (110) and `DOAYA_EMERGENCY_GENERAL` (112).
