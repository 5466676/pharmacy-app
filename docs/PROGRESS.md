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

## Phase 1.5 — Accounting · ⏸ steps 1–6 done; 7–9 paused for Phase 2 (owner, 2026-09-25)

Goal: turn the counter app into a complete pharmacy accounting system (inspired by Karma Soft / Al-Ameen, see `docs/ACCOUNTING_RESEARCH.md`), still fully offline and still built on append-only records so Phase 2 sync stays safe.

### A. Suppliers & purchases (المستودعات والمشتريات)
- **Suppliers** (mutable master data): name, phone, sales rep, notes, credit limit.
- **Purchase invoice** (append-only header + lines), keyboard-first like the POS (scan or search → line):
  - per line: quantity (boxes, or strips when split), **bonus / free goods**, unit price, line discount %, **expiry** (optional), sale price (update the product price if it changed);
  - per invoice: supplier invoice number, invoice discount, transport cost, paid **cash** or **on credit**.
  - Each line opens a batch (`received` event). The **true cost per piece** = what was paid ÷ (quantity + bonus), after discounts and with transport spread across lines. The line total cost is stored exactly; per-piece cost is derived, so rounding can't drift.
- **Supplier ledger** (new append-only `supplier_debt_events`): `purchase_on_credit`, `payment_made`, `return_credited`. This gives a **supplier statement** (كشف حساب), balance, and **debt age**.
- **Purchase return to supplier** (expired / damaged / surplus): a new stock event type `returned_to_supplier`, taken from chosen batches, credited to the supplier or refunded in cash.
- **Purchase price history** per product and supplier: last price, best price.

### B. Cost & profit (التكلفة والأرباح)
- Every `sold` event already records its batch, so the **cost of goods sold** comes from that batch's cost. Returns bring their cost back.
- **Profit** per invoice, product, employee and day; margin %. Products received before this phase have no cost: they're shown as "cost unknown", never guessed.

### C. Shortages → purchase order (النواقص والطلبية)
- Shortage list: under the minimum, out of stock, or selling fast. Each line shows the last supplier and last price.
- One tap builds a **purchase order** per supplier. It can be shared as text (WhatsApp / Telegram) or printed, and turns into a purchase invoice when the goods arrive.

### D. Stocktaking without stopping sales (جرد بدون توقف)
- A stocktake session, optionally limited to certain shelves. Each product is counted on its own. At the moment of counting we record both the counted quantity and the system quantity, so sales can carry on.
- Applying the session writes `adjusted` events linked to it. The report shows shortage and surplus in value (cost).

### E. Expenses & monthly P&L (المصاريف والأرباح والخسائر)
- Expenses (rent, salaries, electricity, generator/ampere, internet, other + custom), paid **from the drawer** (reduces the till's expected cash) or **from outside** (the owner).
- **Monthly profit & loss**: sales − returns − cost of goods − expenses = net profit.
- Purchases paid in cash from the drawer also reduce the till's expected cash.

### F. Automatic backup (النسخ الاحتياطي)
- A daily copy of the database (SQLite `VACUUM INTO`, safe while the app runs) to a chosen folder, such as a USB stick. The last 30 are kept.
- Settings shows the last backup and a "back up now" button. A restore guide is included.

### G. Reports & dashboard
- Dashboard adds: today's profit, supplier debts due, shortages count.
- Owner reports: profit by product / employee / day, stock value at cost, P&L, supplier statements.

### Owner decisions (2026-09-25)
- Purchase invoices: the **owner and employees** can enter them, and each invoice records who entered it.
- **Cost, purchase prices and profit are owner-only**: employees never see them.
- Expenses and cash purchases: **choose each time** whether they come from the drawer or from outside.
- **Receipt printing**: yes, behind a **small, unobtrusive print button** (the printing dependency needs approval; asked at the step-3 review).

### Not in this phase (next, after your review)
Health ministry price-list import · money accounts (drawer / Sham Cash / bank + owner withdrawals) · printed customer statement + credit limit · finer permissions · barcode labels.

### Steps (tests first, a commit after each, **stop for review after step 3**)
1. `doaya_core`: supplier ledger, purchase cost allocation (bonus, discounts, transport), COGS/profit, stocktake deltas, P&L. Unit tests first.
2. Schema v5 + migration (tested from the real v4 schema) + repositories.
3. Suppliers + purchase invoice screen + supplier statement and payments + purchase returns → **review**.
4. Cost & profit reports; dashboard additions.
5. Shortages → purchase orders (share / print).
6. Stocktaking sessions.
7. Expenses + monthly P&L; the till takes expenses and cash purchases into account.
8. Automatic backup.
9. Real Linux build driven end to end + screenshots → **review**.

### Done so far
- [x] Step 1: `doaya_core` supplier ledger, cost allocation (bonus, discounts, transport), profit, stocktake, P&L (69 core tests).
- [x] Step 2: schema v5 + migration tested from the real v4 schema + repositories; the till subtracts drawer purchases, supplier payments and expenses and adds supplier cash refunds.
- [x] Step 3: **المشتريات** in the sidebar (everyone):
  - **Purchase invoice**: scan/search → line (box or strip), quantity, bonus, purchase price, discount %, expiry, new sale price. Invoice discount, transport, cash or credit, and for cash: from the drawer or from outside. F9 saves from anywhere on the screen.
  - The owner gets the last price filled in, and a hint when another supplier was cheaper.
  - **Invoices list**: date, supplier, invoice number, who entered it. Totals and line costs are shown to the owner only.
  - **Supplier page**: balance, age of the oldest unpaid invoice, statement with running balance (owner only); payment (drawer / outside); **return to supplier** by batch, credited to the account or refunded in cash (the owner gets the batch cost suggested as the value).
  - Paying from the drawer (purchase, supplier payment, cash refund from a supplier) needs an open till, like selling.
  - Tests: 58 app tests (invoice flow, supplier page employee/owner, closed-till block). Checked in the real Linux build: `docs/screenshots/phase1_5/`.

- [x] Step 4: **الأرباح** (owner only, in the admin section):
  - Net sales, cost of goods sold, profit with margin, stock value at cost, for today, this week or this month.
  - Grouped by product, by employee or by day, sorted by profit.
  - A sale's discount is spread over its lines. A customer return subtracts its refund and gives its cost back, in the period it happens.
  - Pieces sold from stock received before purchase invoices existed have no cost. They're counted and flagged ("تكلفة ناقصة" plus a notice), never guessed, and the margin is hidden until the cost is complete.
  - Dashboard (owner): today's profit and what we owe suppliers.
  - Tests: 72 core, 60 app. Screenshots `docs/screenshots/phase1_5/07–09`.

- [x] Step 5: **النواقص والطلبيات** (tabs under المشتريات, for everyone; last prices owner-only):
  - Shortages: out of stock, under the minimum, or running out within 14 days at the last 30 days' pace. Most urgent first, with how many days are left.
  - Suggested quantity in whole boxes: enough for 14 days, and back above the minimum. It can be changed or unticked.
  - Supplier: the last one we bought from by default, or picked. "اعمل الطلبيات" makes one draft order per supplier.
  - Order: edit quantities; **انسخ الطلبية** copies a ready message (pharmacy, date, numbered lines "1. Amoxil 500 mg: 6 علبة") to paste in WhatsApp / Telegram, and marks it sent.
  - **وصلت: فاتورة شراء** opens a purchase invoice with the supplier and lines filled in. Saving it marks the order received.
  - The dashboard's low-stock card now opens the shortages.
  - Tests: 75 core, 62 app. Screenshots `docs/screenshots/phase1_5/10–13`.

- [x] Orders by **WhatsApp** (`url_launcher`, approved 2026-09-25):
  - Suppliers have a WhatsApp number, set when adding or editing a supplier (there's now an edit button on the supplier page).
  - "ابعتها واتساب" opens the supplier's chat with the order typed in, through the installed app (`whatsapp://`) or wa.me. If the supplier has no number, it asks for one first. The message is also copied as a fallback.
  - The supplier page has a small chat button.
  - Local numbers get the 963 code (`whatsappNumber`, tested).
- [x] Step 6: **الجرد** (Inventory → جرد):
  - Start a session for the whole pharmacy or one shelf (case-insensitive prefix: "B" covers B1, B2…).
  - Scan or search, then type boxes and loose strips. The count is **blind**: the system quantity isn't shown before counting.
  - The system quantity is recorded at the moment of counting, so selling goes on. A recount replaces the earlier count.
  - Lists of counted and not-yet-counted products; differences with their value at cost (owner).
  - The **owner** applies the session: one `adjusted` movement per difference, linked to the session. Past sessions are listed.
  - Tests: 76 core, 65 app. Screenshots `docs/screenshots/phase1_5/14–16`.

### How to review (step 3)
المشتريات → مورد جديد → فاتورة شراء → scan or search → type quantity, bonus, price… → F9. Then open the supplier: statement, "دفعة للمورد", "مرتجع للمستودع". Sign in as an employee to check the amounts are hidden.

### Question for this review
- **Receipt printing**: OK to add the `pdf` + `printing` packages (well-maintained, pure Dart/Flutter, no Google services, work offline with any system printer, including 80 mm thermal printers installed in Windows)? The button will be a small print icon on the completed sale, nothing more.

## Phase 2 — Backend + sync · 🚧 in progress (plan approved 2026-09-25, with the owner's changes)

Goal: the pharmacy's devices (counter PC, the owner's and employees' phones) share one set of data through a server **on the pharmacy's own computer, over the local Wi-Fi, with no internet needed**. Every device keeps a full copy and keeps selling when the server is off; they catch up when it's back. This is also the base the patient app (Phase 3) builds on. Phase 1.5 steps 7–9 (expenses + P&L, automatic backup, final run) are paused and come back later.

### Owner decisions (2026-09-25)
- Dependencies approved: `uvicorn`, `psycopg` 3, `pyjwt`, `argon2-cffi`, `pydantic-settings`, dev-only `pytest` / `httpx` / `ruff`; Flutter `http`.
- **The server is the pharmacy's computer, on the local network (LAN).** The internet isn't required. If the computer is off, phones keep selling and sync when it's back on.
- **Pharmacies are created by hand for now.** The first one is the owner's mother's pharmacy, used as the pilot.
- **Phone number + password once per device, then the account stays signed in**: for the owner and for employees.
- **Phones sell too** (the owner's and the employees'), for when the computer is off or far away. Every phone downloads the full catalogue and stock, so all devices stay consistent.

### A. Server (`backend/`)
- FastAPI + PostgreSQL 16 + SQLAlchemy 2 + Alembic + Pydantic v2. It runs on the pharmacy PC as a background service that starts with Windows (PostgreSQL's official Windows installer + our server). Docker Compose is kept for Linux, and for the internet server later.
- **Multi-pharmacy from day one** (`pharmacy_id` on every row, a tenant-isolation test), even if a local server holds one pharmacy, because the same code becomes the internet server later.
- It mirrors every table the app syncs (catalogue, customers, suppliers, employees, settings, every ledger, stocktakes, orders), and the server numbers every change with one sequence.

### B. Accounts & devices
- **Creating the pharmacy**:
  - The first time the counter app links to an empty server, it offers to create the pharmacy there with the owner's phone and password, and uploads all its existing history.
  - A command-line tool does the same by hand.
- **Accounts**: the owner and every employee get a phone number + password on the server (the owner sets the employees' in Settings). PINs stay for switching users on the shared counter PC; the PIN hashes sync so any shared device accepts them.
- **Linking a device**:
  - Once, with a phone number + password. The device gets its own long-lived token and stays signed in.
  - An **employee's own phone** opens straight into that employee's session. The counter PC keeps the "who's working?" PIN screen.
- The owner sees every linked device and can **unlink** one (a lost phone): its token stops working at once. JWT (short access + rotating refresh stored hashed), Argon2 passwords, login rate limit.

### C. Sync (push / pull by cursor), local network
- **Finding the server**: the app finds it on the Wi-Fi by itself (a UDP broadcast, standard library only). Typing the PC's address by hand is a fallback.
- **Push**: each device sends its unsynced rows (`synced_at IS NULL`). They're stored idempotently, and the device marks them synced.
- **Pull**: "everything after cursor N" from the other devices, 500 at a time.
- **Merging**: ledgers merge with no conflicts (append-only, UUIDv7). Master data uses last-writer-wins on `updated_at`, with the device id breaking ties.
- **Selling is never blocked by sync.** Two devices selling the last box offline can take stock below zero; that shows in red and a stocktake fixes it.
- Sync runs every 30 s when the server is reachable, plus "زامن هلق". The top-bar chip shows the real state: server not found / syncing / synced at 14:05 / N waiting.
- A newly linked phone downloads the whole pharmacy once, with a progress bar.
- **If the PC's disk dies**, any phone still holds everything and can fill a fresh server. This comes on top of the PostgreSQL daily backup.
- The sync engine lives in `doaya_core` (the network behind an interface), **tests first**. An end-to-end test runs two devices through a real server.

### D. Phones (Android)
- The same app with a phone layout and bottom navigation: **selling** (search; camera scanning can come later), stock, debts, the till/shift, the dashboard and, for the owner, profits and purchases.

### E. Later, for the patient app (Phase 3)
Patients aren't on the pharmacy's Wi-Fi, so the patient app will need a server reachable from the internet. The plan is that the pharmacy's local server syncs up to it with the same protocol whenever the internet is available, and the pharmacy keeps working locally either way. This gets decided with the Phase 3 plan.

### Steps (tests first; a commit after each; **stop for review after step 5**)
1. Server skeleton: settings, health endpoint, pytest against a real PostgreSQL, lint.
2. Schema + first Alembic migration; tenant isolation tests.
3. Accounts: create a pharmacy (from the app or the command line), owner and employee accounts, device linking and unlinking, tokens. Tests.
4. Sync API: push / pull, idempotency, last-writer-wins, cursor paging, isolation. Tests.
5. `doaya_core` sync engine + tests; the app's drift adapter; end-to-end: two devices sell offline, sync, and end up identical → **review**.
6. App: find the server on the Wi-Fi, "ربط بالسيرفر" (creating the pharmacy on first link), sync status, background sync, devices list, employees' phone/password.
7. Phone layout (Android) with selling; an employee's phone opens straight in.
8. Running the server on the pharmacy PC: Windows install guide, service start at boot, daily PostgreSQL backup; a real run (server + PC app + phone app) → **review**.

### Open (asked at the step-5 review)
- **Encryption on the Wi-Fi**: HTTPS with a certificate the server makes itself, trusted the first time a device links. That needs the `cryptography` package on the server. Until then the pilot runs over plain HTTP on the pharmacy's own Wi-Fi.
