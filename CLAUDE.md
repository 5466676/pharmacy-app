# Doaya (دوايا) — engineering rules

Pharmacy platform for Syria: patient app, pharmacy app, admin panel, one backend.
Full spec: `docs/SPEC.md`. Decisions log: `docs/DECISIONS.md`. Status: `docs/PROGRESS.md`.

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
- Arabic RTL only (v1). Numbers in Arabic-Indic digits (`formatArabicNumber` / `toArabicDigits`). Drug names stay Latin, rendered LTR (`LatinText`).
- **Ask before adding any dependency** not in the stack below.
- Tests for ledger, sync and red-flag logic come before the UI that uses them.
- Pharmacy desktop: **no `BackdropFilter`** (use `DoayaTheme.solid()`). Mobile: max ~3 blurred surfaces per screen, only on large surfaces.
- Commit after each working step. Stop at the end of each phase for review.

## Stack
Flutter stable (Riverpod, go_router, drift) · FastAPI + PostgreSQL + SQLAlchemy 2 + Alembic + Pydantic v2 · JWT roles `patient`, `pharmacist_owner`, `pharmacist_employee`, `admin` · WebSocket for case updates.

## Layout
```
apps/pharmacy                                Flutter pharmacy app (Phase 1: offline POS)
apps/patient  apps/admin                     Flutter apps (Phase 3/4)
packages/doaya_ui                            design system + component gallery (example/)
packages/doaya_core                          pure-Dart ids, money, ledgers, FEFO, sales
backend/                                     FastAPI (Phase 2)
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
flutter analyze                               # at repo root
flutter build web --no-web-resources-cdn      # ALWAYS this flag: no Google CDNs (see DECISIONS)
```
Never put "·" next to an Arabic-Indic number (it reads as ٠); use ":" or "،".
After adding a new icon, run `flutter clean` before a release build: the icon tree-shaker's cache went stale and dropped the new glyphs.
Never put glyphs missing from Amiri/Readex Pro (←, ✓, emoji) in strings — use `DoayaIcons`.
Regenerate localizations after editing an `.arb` file: `flutter gen-l10n` inside that package.
