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
.venv/bin/uvicorn app.main:create_app --factory --host 0.0.0.0 --port 8000
```

Settings come from `DOAYA_*` environment variables or `backend/.env` (see `.env.example`).
