# Doaya (دوايا) — Product & technical spec

A pharmacy platform for Syria. Three Flutter clients share one self-hosted backend.

## 1. Product

### 1.1 Patient app (Android, iOS, web)
- Chat with an AI health assistant about symptoms. The assistant asks follow-up questions, produces a **structured case summary**, and sends it to the patient's chosen pharmacy. The patient picks up the medicine there.
- Dose reminders, order status, prescription photo upload, browse the chosen pharmacy's stock, order for pickup.

### 1.2 Pharmacy app (Windows desktop at the counter; Android/iOS for the owner)
- Point of sale, inventory with expiry tracking, customer debts.
- Inbox of AI cases: the pharmacist reviews the case, chooses the medicine, writes the dosage, marks it ready (patient is notified).
- Multiple employees; every sale records **who** made it and on **which device**.

### 1.3 Admin panel (web)
- Pharmacies and their status; patient subscriptions and revenue share.
- Review queue of AI conversations: red-flag cases and replies that pharmacists corrected.
- Knowledge-base curation.

### 1.4 Business model (details later)
Patients pay a monthly subscription. Pharmacies pay a small monthly fee and receive a share per patient. Payments are **not** built in v1 (pay at pickup); an interface is left for local wallets.

## 2. Rules

### 2.1 Medical safety
1. The AI never prescribes, never states a dose to the patient, and never tells a patient they don't need a doctor. Dosing and the final decision always belong to the pharmacist.
2. A **red-flag layer** runs on every patient message **before** the LLM:
   - rule-based keyword/pattern list in Arabic, including Syrian dialect;
   - an LLM classifier as a second check.
   - Red flags include chest pain, shortness of breath, stroke signs, severe bleeding, high fever in infants, suicidal content, etc.
   - On a hit: show an emergency message immediately, stop the consultation, push an **urgent** case to the pharmacy.
3. Every AI reply and every pharmacist correction is logged for admin review. Corrections feed a curated knowledge base used for retrieval (RAG) — never automatic fine-tuning.

### 2.2 Offline-first pharmacy
1. The desktop app must sell with no internet and no server. The local database is the source of truth on each device; sync happens when connectivity returns.
2. Inventory is an **append-only ledger**: `received`, `sold`, `returned`, `adjusted`, `expired_removed`. Current stock = sum of events. Debts likewise: `debt_added`, `payment_received`. This lets multi-device sync merge without conflicts.
3. Every event carries a UUIDv7 id, device id, employee id, and local timestamp. Sync is idempotent (re-sending an event is harmless).

### 2.3 Syria constraints
- No Firebase, no Google Cloud, no services likely to be blocked. Everything self-hostable.
- LLM provider behind an interface speaking the OpenAI-compatible chat API; switch between a hosted model and a local one (LM Studio / Ollama) via config.

### 2.4 Engineering
- No hardcoded colors, sizes, or strings in widgets — everything from `doaya_ui` and ARB files.
- Arabic RTL is the default and only language in v1. Numbers render in Arabic-Indic digits. Drug names stay in Latin script and render LTR inside RTL text.
- Ask before adding any dependency not listed in §3.
- Tests for ledger, sync, and red-flag logic are written before the UI that uses them.

## 3. Stack
- **Clients:** Flutter stable for all three apps. State: Riverpod. Routing: go_router. Local DB: drift (SQLite).
- **Backend:** FastAPI, PostgreSQL, SQLAlchemy 2, Alembic, Pydantic v2. JWT auth with roles `patient`, `pharmacist_owner`, `pharmacist_employee`, `admin`. WebSocket for realtime case updates.
- **Monorepo:**
```
/apps/patient        Flutter (mobile + web)
/apps/pharmacy       Flutter (Windows desktop + mobile)
/apps/admin          Flutter web
/packages/doaya_ui   design system: tokens, theme, components, logo
/packages/doaya_core models, API client, sync engine, ledger logic
/backend             FastAPI service
/design              reference HTML mockups (read-only)
/docs                SPEC.md, DECISIONS.md, PROGRESS.md
```

## 4. Design system — "dark glass"

Reference mockups live in `/design`. Rebuild them in Flutter; never embed HTML.
- `patient_*.html` — **visual** source of truth for the whole brand.
- `pharmacy_*_layout.html`, `admin_*_layout.html` — **layout** source of truth only (drawn in an older light palette); rebuild with the dark tokens.
- All `[bracketed]` text in mockups is a placeholder for real data.

### 4.1 Background
Vertical gradient `#3D5747` → `#2B4034` (55%) → `#22352A`, two large soft blobs (`#5A7866`, `#45604F`) and faint blurred leaf shapes. Optional blurred photo `assets/bg/leaves.jpg` (added later); the gradient is the fallback.

### 4.2 Color tokens
| Token | Value | Use |
|---|---|---|
| bgTop / bgMid / bgBottom | `#3D5747` / `#2B4034` / `#22352A` | background gradient |
| glassFill | `rgba(236,242,234,0.09)` | standard glass surface |
| glassFillStrong | `rgba(236,242,234,0.13)` | hero cards, sheets, bottom nav |
| glassBorder / glassBorderStrong | `rgba(236,242,234,0.20)` / `0.26` | 1px glass borders |
| glassHighlight | `rgba(255,255,255,0.12)` | 1px inner top highlight |
| sageTop / sageBottom | `#DCE8C8` / `#A9C191` | primary button gradient |
| onSage | `#1B3024` | text/icons on sage |
| accent | `#C9DEAE` | active icons, links, selected |
| price | `#C9E0A8` | prices and totals |
| textPrimary | `#EEF3EC` | main text |
| textSecondary | `#C3CEC2` | supporting text |
| selectedTileFill / Border | `rgba(201,222,174,0.18)` / `0.6` | active category tile |
| warningFill / Border / Text / Icon | `rgba(242,196,120,0.14)` / `0.35` / `#F5DDB0` / `#F2C478` | low stock, near expiry, safety notes |
| dangerFill / Border / Text | `rgba(240,120,110,0.16)` / `0.40` / `#F6B7B0` | out of stock, red-flag cases |
| successDot | `#A8D98A` | online, synced, ready |

**Solid variants** (pharmacy desktop, long lists): `surface #33483C`, `surfaceRaised #3A5044`, `border #4A6254`.

### 4.3 Glass rules and performance
- Glass = translucent fill + 1px border + inner top highlight + `BackdropFilter` blur 18 (strong: 22).
- `BackdropFilter` only on large surfaces (hero card, bottom sheet, bottom nav, input bar, dialogs). Max ~3 blurred surfaces per screen.
- Small/repeated elements (list rows, chips, product cards, icon tiles): translucent fill + border, **no** blur.
- Pharmacy desktop: **no BackdropFilter at all** — solid variants only.

### 4.4 Typography
- `Amiri` Bold: display, screen titles, hero headlines, logo wordmark, prices, big numbers.
- `Readex Pro` 300–600: everything else.
- Both bundled as assets (no runtime Google Fonts).

### 4.5 Shape
- Primary button: full pill, sage gradient, `onSage` text, soft shadow.
- Secondary buttons, search, chips: full-pill glass.
- Cards radius 20–30; hero 28; bottom nav 26, floating 12–14px from screen edges; icon tiles 54×54 radius 18; round icon buttons 44.

### 4.6 Logo
Line-art capsule rotated −45°, stroked in `accent`, a divider across the middle and a small plus beside it. `CustomPainter` with a stroke-width parameter.

## 5. Screens → references
| Screen | Reference |
|---|---|
| Patient splash / onboarding | `design/patient_splash_and_logo.html` |
| Patient home | `design/patient_home.html` |
| Patient AI chat | `design/patient_chat.html` |
| Patient product detail | `design/patient_product_detail.html` |
| Patient order (pickup) | `design/patient_order.html` |
| Pharmacy dashboard | `design/pharmacy_dashboard_layout.html` (layout) |
| Pharmacy POS | `design/pharmacy_pos_layout.html` (layout) |
| Pharmacy case detail | `design/pharmacy_case_detail_layout.html` (layout) |
| Admin overview | `design/admin_overview_layout.html` (layout) |

## 6. Phases
- **Phase 0 — Foundation.** Monorepo, docs, `doaya_ui` (tokens, theme + extension, background, glass surface, fonts, logo, core components, desktop shell), component gallery.
- **Phase 1 — Pharmacy core (offline).** drift schema (products with active ingredient for alternatives, ledger events, customers, debts, employees, devices). POS, inventory (expiry, low stock), debts, dashboard. Barcode scanner as keyboard input. Shortcuts: F2 search, F8 debt, Enter complete. Works with no backend.
- **Phase 2 — Backend + sync.** FastAPI, Postgres schema, auth, event sync (push/pull by cursor), pharmacy mobile app.
- **Phase 3 — Patient app + AI.** Patient screens, chat, red-flag layer, LLM interface, case summaries, pharmacy case inbox/detail, WebSocket updates, ready notifications, order-for-pickup.
- **Phase 4 — Admin.** Overview, pharmacies, conversation review queue, knowledge-base curation.
- **Later:** online payment, delivery.

## 7. Working style
Plan each phase in `docs/PROGRESS.md` and wait for approval. Record non-obvious choices in `docs/DECISIONS.md`. Commit after every working step. Ask when the spec is unclear.
