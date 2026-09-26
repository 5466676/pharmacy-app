# Doaya (دوايا) — engineering rules

Pharmacy platform for Syria: patient app, pharmacy app, admin panel, one backend.
Full spec: `docs/SPEC.md`. Decisions log: `docs/DECISIONS.md`. Status: `docs/PROGRESS.md`. Where we are + ready prompts for every remaining step: `docs/HANDOFF.md`.

## Non-negotiables

**Medical safety**
- The AI never prescribes, never states a dose to the patient, never says "you don't need a doctor". Dosing and decisions belong to the pharmacist.
- Red-flag layer runs on every patient message **before** the LLM (Arabic + Syrian dialect keyword/pattern rules, then an LLM classifier). A hit → emergency message, consultation stops, urgent case pushed to the pharmacy.
- Log every AI reply and every pharmacist correction. Corrections feed a curated RAG knowledge base, never automatic fine-tuning.

**Offline-first pharmacy**
- Desktop sells with no internet. Local drift DB is the source of truth per device.
- Inventory and debts are **append-only event ledgers** (no mutable quantity columns). Every event: UUIDv7 id, device id, employee id, local timestamp. Sync is idempotent.

**Syria constraints**
- No Firebase / Google Cloud / likely-blocked services. Everything self-hostable.
- LLM behind an OpenAI-compatible chat interface, switchable by config (hosted / LM Studio / Ollama).
- No payments yet (pay at pickup); keep an interface for local wallets.

**Engineering**
- No hardcoded colors, sizes or strings in widgets: use `doaya_ui` tokens and ARB files.
- Arabic RTL only (v1). **All numbers in English digits** (1,234.50) via `formatNumber`, even inside Arabic text (owner's decision). Accept Arabic-keyboard digits in input (`toLatinDigits`). Drug names stay Latin, rendered LTR (`LatinText`).
- **Ask before adding any dependency** not in the stack below.
- Tests for ledger, sync and red-flag logic come before the UI that uses them.
- Pharmacy desktop: **no `BackdropFilter`** (use `DoayaTheme.solid()`). Mobile: max ~3 blurred surfaces per screen, only on large surfaces.
- Commit after each working step. Stop at the end of each phase for review.

## Stack
Flutter stable (Riverpod, go_router, drift) · FastAPI + PostgreSQL + SQLAlchemy 2 + Alembic + Pydantic v2 · JWT roles `patient`, `pharmacist_owner`, `pharmacist_employee`, `admin` · WebSocket for case updates.

## Layout
```
apps/pharmacy                                Flutter pharmacy app (Phase 1: offline POS)
apps/patient                                 Flutter patient app (Phase 3: Android + web)
apps/admin                                   Flutter web admin panel for the platform owner (Phase 4)
packages/doaya_ui                            design system + component gallery (example/)
packages/doaya_core                          pure-Dart ids, money, ledgers, FEFO, sales
backend/                                     FastAPI server (Phase 2): runs on the pharmacy PC, LAN sync
design/                                      reference HTML mockups — read-only
docs/                                        SPEC, DECISIONS, PROGRESS
```

## How to run
The Dart packages form a pub workspace (root `pubspec.yaml`).
```bash
flutter pub get                               # at repo root, resolves every package
cd packages/doaya_core && dart test           # domain logic (ledger, FEFO, sales)
cd packages/doaya_ui && flutter test          # design-system tests
cd apps/pharmacy && dart run build_runner build   # after editing lib/data/database.dart
cd apps/pharmacy && flutter test && flutter run -d linux   # or -d windows
cd packages/doaya_ui/example && flutter run -d chrome   # component gallery (or -d windows / linux)
cd apps/patient && flutter test && flutter run -d chrome --web-port 8200 --dart-define=DOAYA_API=http://127.0.0.1:8100   # patient app (server needs DOAYA_CORS_ORIGINS=http://localhost:8200)
cd apps/admin && flutter test && flutter run -d chrome --web-port 8300 --dart-define=DOAYA_API=http://127.0.0.1:8100   # admin panel (server needs DOAYA_CORS_ORIGINS=http://localhost:8300; account: app.cli create-admin)
flutter analyze                               # at repo root
cd backend && .venv/bin/pytest && .venv/bin/ruff check .   # server (needs PostgreSQL, see backend/README.md)
./tool/sync_e2e.sh                            # app ⇄ real server end-to-end sync test
flutter build web --no-web-resources-cdn      # ALWAYS this flag: no Google CDNs (see DECISIONS)
```
Prefer ":" or "،" over "·" next to numbers (clearer at the counter).
After adding a new icon, run `flutter clean` before a release build: the icon tree-shaker's cache went stale and dropped the new glyphs.
Never put glyphs missing from Amiri/Readex Pro (←, ✓, emoji) in strings — use `DoayaIcons`.
Regenerate localizations after editing an `.arb` file: `flutter gen-l10n` inside that package.
