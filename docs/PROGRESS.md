# Progress

## Phase 0 — Foundation · ✅ approved (2026-09-25)

### Plan
1. Monorepo skeleton + `CLAUDE.md` + `docs/` (SPEC, DECISIONS, PROGRESS); copy mockups into `/design`.
2. `packages/doaya_ui`:
   - tokens: colors, spacing, radii, sizes, blur, shadows, typography (`DoayaColors`, `DoayaSpacing`, `DoayaRadii`, `DoayaSizes`, `DoayaTypography`)
   - `DoayaTheme.glass()` / `DoayaTheme.solid()` → `ThemeData` + `DoayaTokens` `ThemeExtension`
   - `DoayaBackground` (gradient + blobs + leaves, optional photo)
   - `GlassSurface` (blurred / translucent / solid)
   - bundled fonts: Amiri Bold, Readex Pro 300–600
   - `DoayaLogo` (`CustomPainter`, stroke-width param) + wordmark
   - components: sage pill button, glass pill button, round icon button, glass search field, icon tile, product card, stat card, status chip, case row, floating bottom nav, desktop shell with sidebar
   - Arabic-digit formatting + `LatinText` for LTR drug names
3. Component gallery (`packages/doaya_ui/example`), ARB-localized, with a glass/solid toggle.
4. Tests: number formatting, theme/tokens, component smoke tests in RTL.

### Done
- [x] Monorepo, docs, design references
- [x] Tokens, theme, extension
- [x] Background, glass surface, fonts, logo
- [x] Components + desktop shell
- [x] Gallery
- [x] Tests + analyzer clean

### How to review
- Screenshots: `docs/screenshots/phase0-*.png` (mobile gallery at 430px wide, desktop shell at 1280×880).
- Run it yourself: `cd packages/doaya_ui/example && flutter run -d chrome` (or `-d windows`). Use the زجاج / صلب toggle to switch between glass and solid, and the "واجهة سطح المكتب" button to open the desktop shell.
- `flutter test` in `packages/doaya_ui`: 28 tests (Arabic number formatting, theme tokens, the rule that solid mode never blurs, component behavior).

### Review feedback applied
- Design direction confirmed: "dark glass" (the `glass` page of the design canvas, identical to `/design`).
- Green layer made darker and more saturated (see DECISIONS, 2026-09-25).

### Open questions for review
- `design/*.html` reference a `support.js` that wasn't in the zip. The files still render (static markup); only the preview-harness script is missing.
- The icon set is Material Rounded for now (see DECISIONS). Do you want a custom line-icon set later (needs `flutter_svg` or an icon font)?
- Product images in the gallery are placeholder icons. Where will real product photos come from (pharmacy uploads, a shared catalogue)? That affects the Phase 1 schema.
- Currency is written as "ل.س" after the number. Do you want "ل.س." or "ليرة" instead, and should prices ever show decimals?

## Phase 1 — Pharmacy core (offline) · ✅ ready for review

Goal: the pharmacy desktop app sells, receives stock, tracks expiry and debts with **no internet and no server**. Everything is written as sync-ready events so Phase 2 only adds transport.

### Architecture
- `packages/doaya_core` (pure Dart, no Flutter): event types, ledger math (stock, batches, debts), UUIDv7, money, sale rules. **Tests first.**
- `apps/pharmacy` (Flutter: Windows primary; Linux for dev; Android later in Phase 2): drift DB, Riverpod state, go_router, `DoayaTheme.solid()` on desktop.

### Data model (drift / SQLite)
Master data (mutable, last-writer-wins by `updated_at` + device when synced):
- `products`: id, trade name (Latin), Arabic name (optional), **active ingredient**, strength, form, manufacturer, shelf, sale price, prescription-only flag, low-stock threshold
- `product_barcodes`: product ↔ many barcodes
- `customers`: name, phone, notes
- `employees`: name, role (`owner` / `employee`), PIN hash, active
- `device`: this machine's id + name (generated on first run)

Append-only ledgers (never updated or deleted; each row: UUIDv7 id, device id, employee id, local timestamp, `synced_at`):
- `stock_events`: `received` / `sold` / `returned` / `adjusted` / `expired_removed`, product, **batch (lot no. + expiry date)**, signed quantity, unit cost (on receive), sale id
- `sales` + `sale_lines`: immutable once completed (who, which device, payment `cash` / `debt`, discount, total)
- `debt_events`: `debt_added` / `payment_received`, customer, amount, sale id

Derived (computed, never stored as truth): stock per product = Σ events; stock per batch; near-expiry list; low-stock list; customer balance = Σ debt events.

Selling picks batches **FEFO** (first-expiring first). A sale is one DB transaction: sale + lines + `sold` events (+ `debt_added` if on debt).

### Screens (layouts from `/design`, dark tokens)
1. First run: device name + owner account. Employee picker + PIN at the counter.
2. **POS**: search / barcode (scanner = keyboard input, Enter adds), cart, walk-in vs registered customer, cash / debt, alternatives with the same active ingredient when out of stock. Shortcuts **F2** search · **F8** debt · **Enter** complete.
3. **Inventory**: list + search, product form, receive stock (batch + expiry), adjust, remove expired; filters **low stock** and **near expiry**.
4. **Customers & debts**: balances, history, record payment.
5. **Dashboard**: today's sales, open debts, near-expiry count, recent sales (who / which device).
6. Settings: employees, device name, thresholds.

### Steps (a commit after each)
1. `doaya_core`: UUIDv7, money, event models, ledger + FEFO + debt math, with full unit tests.
2. drift schema + repositories + tests on in-memory SQLite (sale transaction, idempotent event insert by id).
3. App shell: routing, solid desktop shell, employee login.
4. Inventory + receive stock + expiry/low-stock views.
5. POS with keyboard shortcuts + barcode input (widget tests).
6. Customers & debts, dashboard.
7. Demo seed data, Linux build + screenshots for review.

Note: I can build and test on Linux here, but **not produce a Windows `.exe`** in this environment. The code is platform-neutral; the Windows build is one command on a Windows machine (documented in CLAUDE.md).

### Decisions (owner, 2026-09-25)
- Dependencies approved: drift, drift_flutter, drift_dev, build_runner, flutter_riverpod, go_router, crypto.
- Counter login: pick your name, then a 4-digit PIN.
- Currency: any currency is supported. Default is the **new Syrian pound** (2 decimals), with its symbol shown. Code and symbol are editable in settings.
- Expiry: keep it light. The expiry date is **optional** when receiving. Sales automatically take the nearest-to-expiry stock first. The POS warns *"a quantity of this drug expires soon, sell from it first"*, and the dashboard lists near-expiry quantities.
- Product photos: deferred to Phase 3.

### Done
- [x] `doaya_core`: UUIDv7, money, append-only stock/debt ledgers, FEFO, sale rules (32 tests)
- [x] drift schema with SQLite triggers that refuse DELETE and any UPDATE other than `synced_at` on ledger tables; repositories (15 tests)
- [x] App shell, first-run setup, name + PIN login (keypad or keyboard)
- [x] Inventory: filters (low stock / near expiry / out of stock), product form, receive stock (optional expiry), stock count, remove expired, movement history
- [x] POS: barcode = keyboard input, search by name/ingredient, alternatives with the same active ingredient, near-expiry warnings, cash/debt, **F2 / F8 / Enter**
- [x] Customers & debts, record payment; dashboard (today's sales, open debts, near expiry, low stock, recent sales with employee + device)
- [x] Settings (owner only): pharmacy, currency, near-expiry window, employees, demo data
- [x] Tests: 50 core + 28 design system + 47 app (end-to-end flows, migrations v1→v2→v3, returns, strips, reports, till) = 125
- [x] **Real Linux desktop build** driven by keyboard under a virtual display: setup → demo data → scan → sell → debt sale → restart → PIN login. Screenshots: `docs/screenshots/phase1-*.png`

### Bugs found by running the real app (fixed)
- Search debounce could bring stale results back after a barcode scan.
- Long status chips overflowed instead of truncating.
- drift_flutter's default DB location was the user's Documents folder, which OneDrive can sync. Moved to the app support directory.
- "·" next to Arabic digits read as a zero ("متوفر · ٢٤" ≈ ٢٤٠). Replaced with ":" / "،".
- Signs (+/−) could end up on the wrong side of numbers in RTL.

### How to review
- Windows: `cd apps/pharmacy && flutter build windows --release` on a Windows PC (not buildable in this Linux environment; the code has no platform-specific parts).
- Linux: `flutter run -d linux`. First run → setup; Settings → «عبّي بيانات تجريبية» loads sample drugs with near-expiry batches.

### Added after review (owner requests, 2026-09-25)
- **Employee accounts** (owner only): for today / this week (from Saturday) / this month, each employee's sales, cash vs debt, discounts, debt payments collected, returns and cash refunds, **cash to hand in** (cash sales + collected payments − cash refunds), top products, and every invoice with its lines. The admin pages are hidden from employees.
- **Strips:** "strips per box" and a strip price per product. The POS has a box button and a strip button, and stock shows as "٣ علبة + ١ ظرف". Stock is counted in strips; strips-per-box is locked once stock has moved.
- **Returns, both ways:**
  - From an invoice: capped at what was sold minus earlier returns, back into the original batches.
  - Free-form: pick the product, unit and price.
  - Refund in cash, or as a credit against the customer's debt.
- Schema v2 with a migration tested against the exact v1 schema, and checked on a real v1 database.
- Real-app bugs fixed:
  - **Dialogs popped the page instead of closing** (receive/count/payment); now covered by a test.
  - The "و١" ambiguity.
  - The release icon cache (documented).

- **Till (الصندوق)** per employee: open with a float, add or withdraw cash with a reason, close with a count → shortage/surplus. Selling needs an open till; the owner sees every shift in employee accounts.
- **Amount received + change** at the POS, **discount** for everyone, and **transfer (Sham Cash)** as a payment method that doesn't count toward the drawer.
- Schema v3, with the migration tested from the real v2 schema and checked on a real v2 database.

### Still open
- **Receipt printing**: thermal 58/80 mm? (not answered yet)

## Phase 2 — Backend + sync · not started
