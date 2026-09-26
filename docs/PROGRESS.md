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

## Phase 1.5 — Accounting · ✅ all 9 steps done, ready for review (2026-09-25)

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

- [x] Step 7: **المصاريف والأرباح والخسائر**:
  - **«مصروف»** on the till screen (everyone) and on the expenses page (owner):
    - the kind: rent, salaries, electricity, ampere/generator, internet, or «غير شي» with its own name
    - the amount and an optional note
    - **from the drawer** (needs an open till) or **from outside**
  - The till now shows, when present: purchases paid from the drawer, expenses from the drawer, and cash refunds from suppliers. It also refreshes on them: a bug the new test caught.
  - **المصاريف** (owner, in the sidebar) is a month's P&L with previous/next month:
    - sales − customer returns = net sales
    - − cost of goods = goods profit
    - − expenses by kind = **net profit / loss**
    - unknown cost flagged, as in the profit report
    - next to it, the month's expenses with date, drawer/outside, who, and note
  - Tests: P&L repository test (period bounds, returns, expenses by kind); widget test (an employee pays electricity from the drawer and the till drops; the owner adds a custom kind from outside and sees the net loss); expenses page at 360 px. App 82.

- [x] Step 8: **automatic backup on the device**:
  - Every day, while the app is open (checked every hour), a full copy of the database is saved with SQLite `VACUUM INTO`, which is consistent while selling goes on. The newest 30 are kept.
  - It goes to `Documents/Doaya Backups` by default, or to any folder the owner types (a USB stick). If the folder is missing, a warning shows and it's tried again later.
  - Settings → **النسخ الاحتياطي على هالجهاز**: the last backup, «خذ نسخة هلق», the folder, and the latest copies with «استرجع».
  - **Restore** takes effect at the next start, before the database opens. The current database is kept aside as `.before-restore`.
  - On a device linked to the server, restore is not offered: re-joining the pharmacy brings everything back (see DECISIONS).
  - Tests: complete readable copy; not again within 24 h; keep N; another folder; two in one second; restore applied once with the WAL removed and the old database kept; the controller backs up when due at start and on demand. App 87.
- [x] Step 9: **real Linux release build**, on a month of data (demo products, a purchase on credit, daily sales by Rana and Sami, rent / salaries / generator / a custom «تنظيف» expense, last month's rent). Screenshots `docs/screenshots/phase1_5/17–23`:
  - Rana (employee) records electricity from the drawer, and the till drops 200 → 165 with a «مصاريف من الصندوق» line.
  - The owner opens المصاريف: the month's P&L with every kind, unknown cost flagged, a net loss in red, and the month switch (آب shows only its rent).
  - The owner adds 999 from outside, then restores the morning backup and restarts. The 999 is gone, and the old database is kept aside.
  - **Bug found and fixed**: on Linux without `xdg-user-dir`, the Documents folder can't be found, and Riverpod kept retrying the failing provider, so the backup stuck at «عم ناخد نسخة». The default folder now falls back to ~/Documents, then to the app folder.
  - Only the bottom line of the P&L uses the big figure font. Subtotals are bold.

### How to review (step 3)
المشتريات → مورد جديد → فاتورة شراء → scan or search → type quantity, bonus, price… → F9. Then open the supplier: statement, "دفعة للمورد", "مرتجع للمستودع". Sign in as an employee to check the amounts are hidden.

### Question for this review
- **Receipt printing**: OK to add the `pdf` + `printing` packages (well-maintained, pure Dart/Flutter, no Google services, work offline with any system printer, including 80 mm thermal printers installed in Windows)? The button will be a small print icon on the completed sale, nothing more.

## Phase 2 — Backend + sync · ✅ ready for review (plan approved 2026-09-25, with the owner's changes)

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

### Done (steps 1–5)
- [x] **1. Server skeleton**: settings (`DOAYA_*` / `.env`), `/health`, pytest on a real PostgreSQL, ruff, Docker Compose. The token secret is generated on first run when not set.
- [x] **2. Schema** (Alembic `0001`): pharmacies, users, devices, and one generic `sync_rows` table with a change sequence. Tests: uniqueness per pharmacy, sequence order, migrate down and up.
- [x] **3. Accounts** (8 tests):
  - `/setup` (first run only: pharmacy + owner + this device), `/auth/link` (phone + password once), `/auth/token` (device secret → 15-minute token).
  - The owner lists and unlinks devices (takes effect at once) and manages employee accounts.
  - Login rate limit; a CLI to create pharmacies by hand; phone numbers typed in Arabic digits accepted.
- [x] **4. Sync API** (10 tests):
  - Push with idempotent ledgers and last-writer-wins master data (decided in one SQL statement), tombstones, and pull by cursor with paging.
  - Pharmacies isolated; pushes serialised per pharmacy so no change is ever skipped (tested with concurrent pushes).
- [x] **5. Sync on the device**:
  - `doaya_core`: the sync engine (9 tests on an in-memory server with the same rules) and the HTTP client (setup, link, push/pull, automatic token refresh; 5 tests).
  - App schema **v6**: `sync_outbox`, filled by SQLite **triggers** on all 23 synced tables, so no code path can forget a change, and `sync_state`. Migration tested from the real v5 schema.
  - `DriftSyncStore` copies rows generically. Pulled rows don't bounce back; a newer local edit not pushed yet keeps its value; `is_this_device` and `synced_at` stay local.
  - 5 app tests on real SQLite: triggers catch sales, edits and deletions; the PC uploads its history and a new phone gets the same pharmacy; both sell offline and end up identical; a child arriving before its edited parent still applies.
  - **End-to-end against the real server** (`tool/sync_e2e.sh`): the PC creates the pharmacy and uploads; the owner gives Rana an account; her phone links with the number typed in Arabic digits; both sell; after sync both have stock 5 and 2 sales; unlinking her phone makes its next sync refused.
- Totals: server 23, core 90, design system 23, app 70 (+1 end-to-end run by the script).

- [x] **6. Linking from the app and live sync**:
  - **Finding the server**: the server answers "DOAYA?" on UDP 47800 (Python standard library, 3 tests); the app broadcasts with `dart:io` (a test), or the PC's address is typed by hand.
  - **السيرفر والمزامنة** (sidebar, and a tap on the status chip):
    - On an empty server: create the pharmacy (owner phone + password) and upload all history.
    - Otherwise: link with phone + password.
    - Shows the state, pending changes, download progress and «زامن هلق». The owner also sees linked devices (with unlink) and employee accounts (add a phone + password for each employee).
  - **Top-bar chip** shows the real state: not linked / syncing / synced at 14:05 / server missing / device unlinked. Sync runs every 30 s in the background.
  - **First-run screen**: «انضمام لصيدلية موجودة» (device name → find server → phone + password). It registers only this device, downloads everything, and the account's employee is signed in by itself on that device (once per app start, so "switch user" still works).
  - A `SyncApi` interface with an in-memory fake runs 3 widget flows: the owner links the PC; a new phone joins and opens as Rana; server off and unlinked shown.
  - **Real run** (`docs/screenshots/phase2/`), with the real server and the real Linux app:
    - The counter's existing database migrated v5 → v6, found the server on the network, created «صيدلية الشفاء» and uploaded 22 tables of history.
    - A second copy of the app with its own empty database joined, downloaded everything, and opened straight into the owner.
    - It sold Panadol; the counter then showed that sale (device «موبايل سامر») and today's total went from 194 to 212.
  - Fixed after the real run: Tab left the account form (now kept inside it); a server with no pharmacy yet gets a clear name.

- [x] **7. Phone layout**:
  - Below 700 px wide: a slim top bar (pharmacy name, sync chip, switch user) and a floating bottom bar (الرئيسية، البيع، المخزون، الديون، المزيد); «المزيد» lists the rest, without owner pages for employees.
  - **Every screen fits a 360 px phone.** A test opens each one at 360×740 and fails on any layout overflow.
    - POS: one column; the invoice scrolls; result rows on several lines.
    - Dashboard: 2 cards per row.
    - Inventory rows, and debts/returns as a list then details with a back button.
    - Till, profits (2×2 cards, two-line rows), the purchase invoice (lines over the summary, three fields per row), the supplier page (one scrolling column), shortages, sync and stocktake.
  - `PageHeader`, `Panel` and `SplitPanes` adapt by themselves.
  - Android manifest: internet, WhatsApp, Arabic app name (plain HTTP removed with step 9).
  - **APK not built here**: this environment's network blocks Google's Android SDK downloads (403). On a machine with Android Studio: `cd apps/pharmacy && flutter build apk --release`.
- [x] **8. Server on the pharmacy PC**:
  - **Daily backups by the server itself** (Windows or Linux): `pg_dump` into `data/backups`, keeping 30. CLI `backup` / `list-backups` / `restore`; owner endpoint `/backups`. Tested with a real dump and restore. The app shows the owner the server's last backup.
  - **Windows**: `backend/deploy/windows/install.ps1` sets up the Python environment, a database with a random password, the migrations, firewall rules for TCP 8000 and UDP 47800, and a scheduled task that starts the server with Windows and restarts it. PowerShell isn't available here, so the script is **not run yet** and needs its first real run on the pharmacy PC. Linux: a systemd unit.
  - **`docs/INSTALL_SERVER.md`**: a simple Arabic guide (install, link devices, backups, restore, what to do if…).
  - **Real run** (`docs/screenshots/phase2/07–12`):
    - The server took its first backup by itself, then was switched off.
    - The phone (at 360 px) showed «السيرفر مو موجود» and still sold Brufen.
    - The server came back; «زامن هلق» synced; the counter then showed that sale (26 ل.س, «موبايل سامر») and today's total went to 238 over 6 sales.
- [x] **9. Encryption on the Wi-Fi** (owner approved `cryptography`):
  - The server runs HTTPS with a certificate it makes itself (`python -m app.serve`), and discovery announces the certificate's fingerprint.
  - Devices pin it when they link, show its short code (`AB12-CD34`), and refuse any other certificate. That state shows as «السيرفر تغيّر» with an «اربط من جديد» button.
  - Installer, systemd unit, Dockerfile and the end-to-end script were moved to HTTPS.
  - The end-to-end test runs over real TLS: first-contact pinning, linking, syncing, and an impostor certificate refused before anything is sent. Details in DECISIONS.
- Totals: server 34, core 95, design system 23, app 80 (+ the end-to-end script, over HTTPS).

## Phase 3 — Patient app + AI · ▶ steps 1–7 done; step 8 (real run with LM Studio) next (plan approved 2026-09-25)

### Owner answers (2026-09-25)
1. **Hosting**: still being decided. Build it host-agnostic (Docker Compose), and run it locally for now.
2. **The shelf** leaves the pharmacy: medicines and whether they're available, **optionally with product photos**. The patient types the quantity they want; **the pharmacist has the final say**.
3. **AI model**: local, in **LM Studio** (OpenAI-compatible) to start.
4. **Patients see price + available / not available** (no quantities).
5. **Emergency numbers**: only ambulance and emergency, and only if confirmed from Syrian sources.
6. **Notifications matter, especially dose reminders and case/order updates**, including when the app is closed. Reminders: scheduled local notifications. Updates with the app closed: a background mechanism without Google (options and any extra dependency asked at step 7).
7. **Subscriptions off** for the pilot.
- **Dependencies approved**: `httpx` (runtime), `websockets`, `python-multipart`; `web_socket_channel`, `flutter_local_notifications`, `image_picker`.
- **Order**: first finish Phase 1.5 (steps 7–9), then Phase 3.


Goal: a patient describes symptoms to an AI assistant in their own dialect, and gets a clear summary sent to **their chosen pharmacy**. The pharmacist decides the medicine and the dosage and marks it ready, and the patient is told and picks it up (pay at pickup). Patients can also browse that pharmacy's shelf and order for pickup. Safety rules (CLAUDE.md, SPEC §2.1) apply to every step.

### A. Architecture: one server on the internet, the pharmacy stays local
Patients aren't on the pharmacy's Wi-Fi, so something must be reachable from the internet.
- **Central server ("دوايا أونلاين")**: the same FastAPI code (it has been multi-pharmacy from day one) on a rented server with a real domain and a normal certificate. It holds:
  - patients
  - the list of pharmacies taking part
  - AI consultations, cases and orders
  - each pharmacy's **published shelf**
- **The pharmacy keeps working locally, exactly as now.** POS, stock, debts and sync stay on the pharmacy's own server and Wi-Fi.
- **Bridge** (a small job inside the pharmacy's local server): whenever there's internet, it publishes the shelf up to the central server: products, prices and "available / not available". **Recommended: nothing else leaves the pharmacy** (no sales, debts, customers or quantities). That keeps the patient side simple and the pharmacy's books private. It uses the same push-by-cursor idea as Phase 2.
- **Case inbox**: the pharmacy's devices (PC and phones) talk to the central server directly over the internet, with a WebSocket for live updates. A case needs the internet anyway, because the patient is on the internet. With no internet, the inbox shows "no internet" and selling goes on.
- **A pickup becomes a normal sale**: the pharmacist opens the ready order in the POS with the cart already filled, so stock and the till stay right.

### B. The AI consultation (server side, **tests before any UI**)
Every patient message goes through this pipeline, in order:
1. **Red-flag rules**, before any LLM:
   - Arabic text is normalized first: diacritics and tatweel removed; أ/إ/آ→ا, ى→ي, ة→ه unified; Arabic digits converted.
   - Then keyword and pattern rules cover formal Arabic **and Syrian dialect**. Examples:
     - «وجع بصدري»
     - «ما عم اقدر اتنفس» / «نفسي مقطوع»
     - «تمّه معوّج» / «ايدي نملت فجأة»
     - «عم ينزف كتير»
     - «ابني عمره ٣ شهور وحرارته ٣٩»
     - «بدي موّت حالي»
     - poisoning / an overdose taken
     - pregnancy with bleeding
     - convulsions, fainting, severe allergy (swollen face or throat)
   - Negation is handled conservatively: «ما عندي وجع بصدري» doesn't fire. When in doubt, it fires.
   - A large table of example sentences, the ones that must fire and the ones that must not, is written **first**.
2. **LLM classifier** as the second check: it returns strict JSON `{red_flag, category, reason}`. If the model is down or its answer can't be parsed, the rules alone decide, and the case is never silently dropped.
3. **On a hit**:
   - The emergency message shows at once, with the emergency numbers (to confirm: ambulance 110).
   - The chat stops.
   - An **urgent** case goes to the pharmacy with the conversation so far, and it rings on the pharmacy's screen.
4. **Assistant** (OpenAI-compatible chat API: hosted / LM Studio / Ollama, chosen in settings):
   - It asks short follow-up questions, one at a time, with quick-reply chips like the mockup: symptoms, how long, age, sex, pregnancy / breastfeeding, allergies, current medicines, chronic conditions.
   - Its system prompt is versioned. It **never** names a dose, never recommends or prescribes a medicine, and never says a doctor isn't needed.
5. **Output guard**, after the LLM and before the patient sees anything:
   - It checks the reply for doses (mg, «حبة كل…», «مرتين باليوم»…), prescribing phrases, and "you don't need a doctor".
   - A reply that fails is replaced with a safe line («هالسؤال بيجاوبك عليه الصيدلي»), and the failure is logged for review.
6. **Case summary**:
   - The LLM fills a fixed JSON schema: symptoms, duration, age, sex, allergies, medicines, conditions, and the red flags asked about and denied. The schema is checked, and the model retries once if it doesn't fit.
   - The patient sees the summary, can correct it, and presses «ابعت للصيدلية».
7. **If the model is down**, the patient can still send their message straight to the pharmacist as a case without a summary. The consultation never becomes a dead end.
8. **Logging**:
   - every message
   - every AI reply, with the model, prompt version and red-flag result
   - every guard replacement
   - every pharmacist correction (a wrong summary or a wrong question), with the corrected text

   This is the review queue and the curated knowledge base of Phase 4. It is **never used for automatic fine-tuning**. Phase 3 already leaves a retrieval hook (empty knowledge base) in the prompt.

### C. Pharmacy app: the case inbox (from `design/pharmacy_case_detail_layout.html`)
- **Inbox**: new (urgent on top, in red, with a sound), ready, picked up. The top-bar badge shows new cases.
- **Case detail**:
  - the AI summary
  - the red flags that were asked about and denied
  - the full conversation
  - **the customer's history at this pharmacy** if their phone number matches a customer (past purchases, debt)
- **The pharmacist's decision** («القرار والجرعات دايماً عند الصيدلي»):
  - Add medicines from stock (with the available quantity).
  - Write how to use each one (the pharmacist's own words, plus optional structured times per day and number of days for reminders).
  - «جاهز، بلّغ المريض».
  - «اسأل المريض سؤال» (goes into the patient's chat).
  - «بحاجة طبيب» (the patient is told to see a doctor; the case closes).
- **«صحّح المساعد»** on any AI summary line or question, logged as a correction.
- **Pickup**: «استلم» opens the POS with the cart filled, and the sale is recorded normally, with who sold it and on which device.
- Owner and employees both see the inbox, and every action records who did it.

### D. Patient app (`apps/patient`, Flutter: Android + web first; iOS later)
Screens from `design/patient_*.html`, same `doaya_ui` dark glass, RTL, English digits.
- **Onboarding and account**: phone number + password (no SMS in v1), name, birth year, sex. Staying signed in works as on the pharmacy's devices.
- **Choosing the pharmacy**: a list by city, or typing the short code the pharmacy shows at its counter (a QR code later). It can be changed later.
- **Home**: «حاسس بشي؟ احكيلي», categories, «متوفر بصيدليتك».
- **Chat**:
  - bubbles, quick replies, the summary card
  - «وصلت للصيدلية»
  - the fixed safety line («إذا صار عندك ضيق نفس… روح عالطوارئ»)
  - the full emergency screen
- **Case status**: sent → the pharmacist is preparing it → ready → picked up. Updates arrive live while the app is open (WebSocket), and are checked on opening otherwise.
- **The pharmacy's shelf**: search, product detail («اسأل صيدليتك عن الجرعة»), and **order for pickup** with a note for the pharmacist. Pay at pickup. A small payment interface is left in place for local wallets later.
- **My orders**.
- **Reminders («جرعاتي»)**: built from the pharmacist's structured instructions and shown as local notifications on the phone. No server push is involved, so no Firebase.
- **Prescription photo**: attach a photo to a case or order. The server stores it privately and only the chosen pharmacy sees it.

### E. Questions for you before starting
1. **Where the central server lives**:
   - a rented server outside Syria (cheap and reliable, but paid by card), or
   - a hosting company inside Syria.

   Plus a domain name for it (e.g. `doaya.app`, if available).
2. **What leaves the pharmacy**: only the shelf (names, prices, available yes/no), as recommended? Or also a full off-site backup of everything?
3. **Which AI model first**:
   - a hosted OpenAI-compatible service (billing and access from Syria vary), or
   - a local model (Ollama / LM Studio) on a machine with a GPU.

   For the pilot it can run in LM Studio on your own PC.
4. **Patients see**: price + "available / not available" (recommended), or the exact quantity too?
5. **Emergency numbers** to show: ambulance 110? Anything local to add?
6. **Notifications with the app closed**:
   - v1 = local reminders + live updates while the app is open (recommended).
   - Real push with the app closed would need a self-hosted push service (ntfy / UnifiedPush) later.
7. **Subscriptions** stay off for the pilot (free), right?

### F. Dependencies to approve
- **Server**:
  - `httpx` as a runtime dependency (the LLM client; it is already a test dependency)
  - `websockets` (WebSocket support in uvicorn)
  - `python-multipart` (photo upload)
- **Flutter**:
  - `web_socket_channel` (live cases in both apps)
  - `flutter_local_notifications` (dose reminders, and the new-case sound/alert on the pharmacy's phones)
  - `image_picker` (prescription photos)

### Steps (tests first; a commit after each; **stop for review after step 4 and after step 8**)
1. **Red-flag rules**: normalization + rules, with a large example table (must fire / must not fire) written first.
2. **LLM interface**: OpenAI-compatible client switchable by settings, a scripted fake model for tests, the red-flag classifier, and the output guard (dose / prescribing / "no doctor" tests).
3. **Consultation engine**: the pipeline above, follow-up questions, summary schema + validation, the model-down fallback, and logging of every AI reply. Tests with the fake model, including an emergency mid-chat.
4. **Central server**: patient accounts; the pharmacy list and published shelf; cases, messages and orders APIs; WebSocket; the local server's bridge; tenant isolation (a pharmacy only sees its own cases). Tests → **review**.
5. **Pharmacy app**: case inbox + case detail + decision; urgent alert; «اسأل المريض»; «بحاجة طبيب»; corrections; pickup into the POS. Phone layout too.
6. **Patient app**: new app skeleton, onboarding and account, choosing the pharmacy, home, chat with the emergency screen, case status.
7. **Patient app**: the shelf, product detail, order for pickup, my orders, reminders, prescription photo.
8. **Real run**: central server (in Docker here, standing in for the internet), a pharmacy's local server and PC app, the patient app on web and at phone size. Covers a normal case to pickup, a red-flag case, the model switched off, and the internet cut at the pharmacy → **review**.

### Done
- [x] Step 1: **red-flag rules** (`backend/app/consult/redflags.py`), with the example table written first (`tests/test_redflags.py`).
  - Normalization: diacritics and tatweel removed; أ/إ/آ→ا, ى→ي, ة→ه; Arabic digits → Latin; stretched letters folded («كتيييير»).
  - 12 categories: chest pain, breathing, stroke, heavy bleeding, feverish baby (up to 3 months), self-harm, poisoning / overdose, seizure, unconscious, severe allergy, pregnancy with bleeding, stiff neck / worst headache.
  - Formal Arabic and Syrian dialect, plus a few English phrases.
  - Negation cancels a symptom only when it comes just before it, in the same clause («ما عندي وجع بصدري», «ولا ضيق نفس»). «بس / لكن / و…» start a new clause, and negation **never** cancels self-harm, poisoning or a feverish baby.
  - Examples: 54 that must fire; 27 everyday pharmacy sentences that must not («حرقة بالمعدة», «تشنج بالعضل», «رح موت من الجوع», «عندي صرع وبدي علبة الدوا», «لقاح شلل الأطفال»). A guard test checks every pattern is written on normalized text; it caught «على» in one.
  - Emergency numbers are settings: ambulance **110** (the Ministry of Health's unified operations room, 2026) and **112** (police / emergency). Server 83.
- [x] Step 2: **model interface, classifier, output guard** (`backend/app/consult/`):
  - `OpenAICompatibleLLM`: `POST …/chat/completions` to LM Studio by default (`DOAYA_LLM_BASE_URL/MODEL/API_KEY`); Ollama or a hosted API by settings.
    - JSON mode, falling back without it when a local server refuses it.
    - `<think>` blocks of reasoning models stripped.
    - Every failure becomes one `LLMUnavailable`.
  - `ScriptedLLM` for tests; `parse_json` finds the object even inside prose or ```json.
  - **Classifier** (second red-flag layer): reads the last 6 messages, so a bare «اي» to «في تيبّس بالرقبة؟» counts. It returns strict JSON with a category. It can only add an alarm; a down model or an unreadable answer → the rules alone decide.
  - **Output guard** on every assistant reply:
    - doses (units, «حبتين مرتين باليوم», «ملعقة ٣ مرات يومياً»)
    - prescribing («خود بنادول», «جرب Brufen», «بنصحك بمضاد حيوي»)
    - "no doctor needed" («ما في داعي تروح للدكتور»)
    - while normal questions and «لازم تروح للدكتور» pass
  - Dependencies added (approved): `httpx` (runtime), `websockets`, `python-multipart`. Server 154.
- [x] Step 3: **consultation engine** (`app/consult/engine.py`): one patient message → rules → classifier → assistant → guard → summary.
  - Rules hit → the emergency message with 110 / 112 and **no model call at all**. Self-harm gets its own gentler words.
  - The assistant prompt (`assistant-v1`, versioned in every log) asks one short question at a time in Syrian Arabic, with up to 3 quick replies, and never names a medicine or a dose or says no doctor is needed. It knows the patient's profile so it doesn't ask again, and has a hook for curated knowledge-base notes (empty until Phase 4).
  - When the assistant is `ready` (or after 8 patient messages), a **case summary** is built: a validated schema (symptoms, duration, age, sex, pregnancy, allergies, medicines, conditions, denied danger signs, notes), with one retry with the validation error.
  - **The model down never blocks the patient**: a fallback turn offers to send the message straight to the pharmacist. With everything down the rules still stop emergencies.
  - Every step returns log entries (`red_flag`, `assistant_reply` with model / prompt / raw, `guard_block`, `summary`, `llm_down`) for the API to store.
  - 10 engine tests with a scripted model (a bare «اي» caught by the classifier; the guard replacing «خود بنادول حبتين كل 8 ساعات»). Server 164.
  - A run against a real LM Studio model needs a machine with one; it's in the step 8 checklist for your PC.
- [x] Step 4: **central server** (same FastAPI code; migration `0002`). Server 183 tests.
  - **Patients**:
    - phone + password once (no SMS), then a long-lived session secret (stored hashed) traded for 15-minute tokens
    - profile: birth year, sex, city, chosen pharmacy
    - logout
    - patient and pharmacy tokens are refused on each other's endpoints
  - **Directory**: listed pharmacies by city, by name, or by the short code shown at the counter (`app.cli list-pharmacy <id> --code SH4F --city دمشق`).
  - **Pharmacy key**: `app.cli pharmacy-key <id>` → `DOAYA_CENTRAL_KEY` on that pharmacy's own server (stored hashed on the central one).
  - **Shelf**:
    - The pharmacy's server computes it from its synced rows: active products, price, and available = stock ledger > 0.
    - It publishes the whole shelf every 10 minutes when there's internet. Only names, prices and available-or-not leave the pharmacy.
    - Patients browse and search it; available items come first, and no quantities are shown.
  - **Consultations → cases**:
    - The patient chats through the step-3 pipeline, checks and corrects the summary (the edit is logged), and sends it, or sends the plain chat if the model is down.
    - An emergency goes to the pharmacy at once as **urgent**, listed first.
    - After sending, the patient's messages go to the pharmacist, still through the red-flag rules first.
  - **Pharmacy side** (key + the pharmacist's name in `X-Doaya-Actor`):
    - list and open cases, with the patient's name, phone, age and sex, so the app can match its own customer
    - «اسأل المريض سؤال»
    - the **decision**: medicines, quantities, the pharmacist's own instructions, optional times/day and days for reminders → ready
    - picked up / needs a doctor / close
    - **corrections** of an assistant message or a summary field → `ai_log`
  - **Pickup orders** from the shelf: the patient asks for quantities; the pharmacist sets the final ones (0 drops a line) with a note. Transitions are checked. The patient can cancel until it's handled.
  - **Live updates**:
    - `/ws` WebSocket (patient token or pharmacy key) with a ping every 25 s
    - `/updates?since=` and `/pharmacy-api/updates?since=` so a phone can check in the background and nothing is lost while offline
  - **The pharmacy's devices** reach all this through **their own server**, at `/central/cases|orders|updates…`. It adds the key and the account's name, so no second login is needed, and devices never hold the central key. With no internet only these calls fail.
  - Isolation tests: another pharmacy's key can't see a case or an order; another patient can't open a consultation.

### How to review (step 4)
Server side only so far (the screens are steps 5–7). The tests read as the scenarios:
- `backend/tests/test_consultations.py`: from the first message to pickup; an emergency; a red flag after sending; the model down; isolation; corrections.
- `test_orders_live.py`: orders with the pharmacist's final quantities, background updates, WebSocket, a device going through its own server.
- `test_redflags.py`: the sentence tables.
- `test_directory.py`: the shelf from synced rows.
- [x] Step 5: **the pharmacist's side in the pharmacy app**:
  - **«الحالات»** in the menu. Everyone sees it once the pharmacy is on Doaya online; the owner always sees it, to link it. It carries a badge with what's waiting.
  - A new **urgent** case rings (system alert sound) and shows «وصلت حالة مستعجلة: …».
  - The inbox refreshes every 15 s through the pharmacy's own server (`/central/…`). With no internet it says so, and selling is untouched.
  - **Case list**: urgent first in red, with the red flag named («ألم بالصدر»), status, patient and time.
  - **Case page** (from `design/pharmacy_case_detail_layout.html`):
    - the patient: name, age, sex, phone
    - an urgent banner telling the pharmacist to call them
    - **the assistant's summary**, with what the patient ruled out («نفى: …»)
    - the whole **conversation**
    - **«سجلّه عندك»**: the customer with the same phone, their debt and last purchases
    - **«صحّح»** on the summary or any assistant message → logged for review
  - **The decision** («القرار والجرعات دايماً عند الصيدلي»):
    - add medicines from stock, showing what's available in boxes/strips
    - quantity and **the pharmacist's own instructions** (required), with optional times/day and days for the patient's reminders
    - a note
    - **«جاهز، بلّغ المريض»**, «اسأل المريض سؤال», «بلّش التحضير», «بحاجة طبيب» (with an optional word), «سكّر الحالة» for emergencies
  - **Pickup orders**: the patient's note; per line what they asked for, the price and our stock. The pharmacist sets the final quantities (− down to 0 drops a line), then ready / «ما في», with a note to the patient.
  - **«استلم وبيع»** (a case or an order): the POS opens with the cart filled, as far as stock allows. After the sale it's marked picked up on Doaya online. The sale is a normal one (till, stock, who, device). With no internet the sale still goes through and the case stays "ready".
  - **The owner links Doaya online** in «السيرفر والمزامنة»:
    - the address + the pharmacy key
    - checked with the central server, then kept on the pharmacy server (`data/central.json`, 600)
    - «فك الربط» undoes it
  - Phone layout: list, then the case / order on its own page.
  - **Real run** (`docs/screenshots/phase3/`), on one machine:
    - Doaya online on :8100, the pharmacy server over HTTPS :8443, the Linux app linked to both
    - a stand-in for LM Studio answering in its API format
    - two patients played through the real API
    - The shelf reached Doaya online by itself (Augmentin shown unavailable). The consultation went question → summary → sent. The emergency («وجع بصدري ونفسي مقطوع») stopped before any model call and rang at the counter.
    - The pharmacist gave Panadol with «حبة كل 8 ساعات بعد الأكل». The patient saw it ready with those words. «استلم وبيع» sold it and the patient saw `picked_up`. The order went from 2 Panadol + 1 Omega to 2 Panadol with «الأوميغا خالصة هلق».
  - **Bugs found by the real run and fixed**:
    - A false «ما في إنترنت» banner every so often. The server closed idle connections after 5 s while the app reused them for 15 s. The app now drops idle connections after 4 s and the server keeps them 65 s. The same bug could make sync show «السيرفر مو موجود» at random.
    - The address hint showed reversed in RTL.
    - Search results needed a Material wrapper (caught by a widget test).
    - Stock showed in strips instead of boxes/strips.
  - Tests: server 184, app 93 + the end-to-end script (6 new inbox tests with a fake Doaya online: link, case to pickup at the POS, ask / needs a doctor, order quantities to pickup, no internet, phone pages).
- [x] Step 6: **the patient app** (`apps/patient`, Android + web; the same `doaya_ui` glass design):
  - **Account once**: «حساب جديد» (name, phone, password; birth year, sex and city optional, with why we ask) or «عندي حساب». The session stays on the device (a file on Android, the browser's own storage on the web). With no internet the app opens on the last known profile.
  - **Choosing the pharmacy**: by the code at the counter (`SH4F`) or from the list of the patient's city. «غيّر» from the account page.
  - **Home** (from `design/patient_home.html`): the pharmacy, «حاسس بشي؟ احكيلي» → a new consultation, the last 3 consultations with their state, and the emergency line («إذا صار عندك ضيق نفس أو ألم بالصدر…»). The shelf comes in step 7.
  - **The chat** (from `design/patient_chat.html`):
    - the patient in sage, the assistant in glass, the pharmacist with their name
    - the assistant's quick replies as buttons
    - «ابعت المحادثة للصيدلي مباشرة» at any time
    - **the summary to check**: every field in plain words, «عدّل» (a form; lists split by comma) and «ابعته للصيدلية»
    - then the steps وصلت → عم يتحضّر → جاهز → استلمت, and **what the pharmacist prepared**: each medicine with the pharmacist's own instructions, their note, «استلام من …، الدفع عند الاستلام»
    - **an emergency**: a red panel with two large buttons, «الإسعاف 110» and «الطوارئ 112», which dial straight away (changeable at build time). The patient can still write to the pharmacy.
    - a finished consultation can't take new messages
  - **Live**: the server's WebSocket while the app is open. When it's down the app asks `/updates` every 30 s and reconnects (2 s up to 1 min). A new token on every connect.
  - **The server**: `DOAYA_CORS_ORIGINS` lets the web app call the server from another address (off by default; tested).
  - **Real run** (`docs/screenshots/phase3/10–21-patient-*.png`, 390×844 at 2x):
    - the web build (`--no-web-resources-cdn`) in Chromium against Doaya online :8100, with the stand-in for LM Studio
    - sign-up → the pharmacy → question with quick replies → the summary → sent
    - the pharmacist (through the API) started preparing, then decided (Paracetamol, ORS, a note). **The chat updated by itself** over the WebSocket.
    - «عندي ألم بالصدر وما عم اقدر اتنفس» → emergency with 110 / 112
  - **Fixed after the real run**: «صيدلية صيدلية الشفاء متابعة» in the chat header, and «الإسعاف 110» cut off on a phone (the two buttons are now full width, one above the other). A widget test caught localizations being read in `initState` on the pharmacy page.
  - Tests: patient app 9 (API, sign-in kept after a restart, the whole flow from sign-up to sending the summary against an in-memory server, an emergency, live updates and the polling fallback). Server 185.
- [x] Step 7: **the shelf, orders, dose reminders, notifications, prescription photos** (owner approved `workmanager`, 2026-09-26):
  - **The shelf** (from `design/patient_home.html` and `patient_product_detail.html`):
    - «متوفر بصيدليتك» on the home page and a search («دوّر على دوا أو منتج…»); price and available-or-not only, never quantities
    - the product page says «بوصفة» / «بدون وصفة»; an unavailable product can't be ordered
    - `GET /directory/{id}/shelf/{product}` so a product page survives a reload on the web
  - **Pickup orders** (`design/patient_order.html`):
    - a cart per pharmacy (emptied if the pharmacy changes), a note, «أرفق صورة الوصفة», where to pick it up and the hours, the total, «الدفع عند الاستلام بالصيدلية»
    - «طلباتي» with each order's steps. The pharmacist's final quantities show as «طلبت 2، الصيدلي حضّر 1». The patient can cancel until the pharmacy handles it.
  - **«جرعاتي» (dose reminders)**:
    - only from the pharmacist's decision (times per day, days), from «ذكّرني بالجرعات» under it
    - default times over waking hours (3 a day: 08:00, 14:00, 20:00). The patient can move them by half an hour; the number of doses is the pharmacist's.
    - each notification carries **the pharmacist's own words**
    - the next 60 doses are scheduled on the phone, topped up at every start and background round. Nothing goes through a server.
  - **Notifications** («حضّرلك الصيدلي دواك», «طلبك جاهز للاستلام», needs a doctor, rejected):
    - app open: from the live socket
    - app closed: `workmanager` asks `/updates` about every 15 minutes when there's a connection (Android's own scheduler, no Google push)
    - the first check only learns (no flood of old news); tapping one opens its chat, order or «جرعاتي»
    - web: reminders are listed and the page says notifications come on the phone app
  - **Prescription photo**: the camera button in the chat, or with an order.
    - Shrunk on the phone (~1600 px, JPEG 80). The server checks the bytes (JPEG, PNG, WebP) and a 5 MB limit, and keeps it in `<data_dir>/photos`.
    - Only the patient and, once sent, the pharmacy it went to can open it (migration `0003`).
    - The pharmacist sees it in the case conversation and on the order, full size on a click, through the pharmacy's own server.
  - **Receipt printing** (owner approved `pdf` + `printing`): «اطبع الإيصال» on the sale message opens the system print dialog with an 80 mm receipt. It shows pharmacy, sale number, cashier, customer, lines, discount, total, payment, paid and change, in English digits (sample: `docs/screenshots/phase3/22-receipt-sample.pdf`).
  - **Real run** (`docs/screenshots/phase3/23–29-patient-*.png`), the web build against Doaya online with the stand-in model:
    - shelf → product → cart with a photo → order
    - the pharmacist opened the photo (`image/png`) and set the order ready with a note; the order page updated by itself
    - a consultation → the pharmacist's decision (Ospamox 3 a day for 7 days) → «ذكّرني بالجرعات» → «جرعاتي» with 08:00, 14:00, 20:00
  - **Bugs found and fixed**:
    - **The receipt printed Arabic letters broken.** The PDF shapes Arabic with presentation-form glyphs, which Readex Pro doesn't have. It now prints with Amiri, and a test checks the font has all of them.
    - On the order page the photo stretched to the full width.
    - After sending an order, "back" returned to the empty cart; it now goes to «طلباتي».
    - «لـ 7 أيام» read badly; now «كورس 7 أيام».
  - Tests: patient app 27, pharmacy app 97, server 189, core 95.



## Themes: colour choices and a custom theme · ✅ done 2026-09-26, waiting for review

Users asked for other colours, and for a place to make their own.

### What the user gets (revised after the owner's feedback: more colours, more styles, more control)
Preview: the «ألوان دوايا» page (version 2). Choices are made in «المظهر» (the pharmacy app's settings, «حسابي» in the patient app, later in admin), with a live preview:
- **Style («النمط»)**:
  - «زجاجي»: today's look, translucent and blurred
  - «مسطّح»: solid colours, no shadows
  - «ناعم»: rounder, soft shadows
  - «خطوط»: minimal, thin frames, small corners
  - «تباين عالي»: for weak eyesight and sunlight; contrast 7:1, thick borders
- **Mode («الوضع»)**:
  - «ليلي» (night)
  - «نهاري» (day)
  - «أسود كامل» (pure black: saves battery on OLED phones)
  - «تلقائي» (follows the phone or PC)
- **Colours («الألوان»)**: 11 ready palettes, each with a night and a day background, plus «تصميمي» (the main colour and the background, from a colour picker). The palettes are:
  - أخضر دوايا
  - كحلي
  - خمري
  - بنفسجي
  - سماوي
  - زهري
  - عنبري
  - زيتي
  - نعناعي
  - رملي
  - فحمي
- **Details**:
  - corners (sharp to round)
  - blur strength (glass only)
  - text size: small / normal / large / extra large; large is for older patients
  - spacing: comfortable / compact; compact fits more rows at the counter
  - heading font: ornate Amiri / plain
- **Rules that never change**:
  - Red means danger and amber means a warning, in every choice. No palette has a red main colour, so a normal button never looks like an alarm.
  - Any colour hard to read is adjusted automatically: 4.5:1 normally, 7:1 in «تباين عالي».
  - English digits; drug names Latin, left to right.
  - **The pharmacy desktop never blurs**, even in «زجاجي» (old PCs).
- Saved **per device**, never sent to a server.

### How (engineering)
- `doaya_ui`: a `DoayaPalette` holds every colour token. The four presets plus `DoayaPalette.custom(main, background)` derive the rest. `DoayaColors.*` keep their names and read the current palette, so screens don't change. Places that were `const` because of a colour lose `const` (mechanical; the analyzer lists them).
- The solid (no-blur) desktop mode keeps working with every palette.
- **Tests first**: every preset and a sweep of custom colours pass the contrast check; safety colours never change; the choice survives a restart.
- The component gallery shows all themes side by side.

### Steps
1. `DoayaLook` (style, mode, palette, details) → derived palette + surface rules; contrast tests over every palette × mode × style and a sweep of custom colours; safety colours never change (`doaya_ui`).
2. `DoayaColors`, radii, text scale and density read the current look; remove the colour `const`s; all apps still pass their tests.
3. «المظهر» screen with the live preview, in the pharmacy app and the patient app; kept per device; «تلقائي» follows the system.
4. Screenshots of each style and mode on desktop and phone → review.

### Done
- Steps 1–4 done. The owner chose «المظهر للكل»: every user of every app picks the look, kept per device (pharmacy: `look.json` in the app support folder; patient: the device store).
- `doaya_ui`: `DoayaLook` + `DoayaPalette.of()` derive every colour with contrast checks; the default look gives exactly the old colours. `DoayaLookScope` applies a look live (screens keep their state). `DoayaLookEditor` is the shared «المظهر» screen body.
- Pharmacy app: «المظهر» in the side menu for everyone (and in «المزيد»). Desktop never blurs, even with «زجاجي».
- Patient app: «المظهر» in «حسابي».
- 589 `const`s that held a colour or size were removed with an analyzer-driven script; no screen code changed otherwise.
- Screenshots: `docs/screenshots/themes/` (patient web in 7 looks + the «المظهر» screen; pharmacy desktop in 4 looks).
- Tests: `doaya_ui` 30 (every palette × mode × style and a sweep of custom colours pass the contrast rules; safety colours keep their meaning), pharmacy 98, patient 28.

## Phase 4 — Admin panel · ✅ done 2026-09-26, waiting for review

From SPEC §1.3 and `design/admin_overview_layout.html` (layout only, rebuilt in the dark tokens). Subscriptions and payments stay **off** (owner's decision for the pilot); the screens say so instead of showing fake numbers.

### A. Server (tests before any screen)
- **Admin accounts**: role `admin` on the central server only, created with `app.cli create-admin` (no sign-up screen). Phone + password once, then long sessions like the pharmacist's, with a sign-in limiter.
- **Overview** (last 30 days): pharmacies (active / waiting / suspended, new this month), patients (registered, active this month), consultations today, **the pharmacists' median response time** (sent → first pharmacist action), urgent cases, orders.
- **Pharmacies**: the list with city, code, patients, response time and state. Actions: approve, suspend (its patients see «الصيدلية مو متاحة هلق»), list/unlist in the directory, issue a new key (the old one stops).
- **Review queue** («مراجعة المحادثات»), from the AI log:
  - red flags (rules / classifier)
  - replies blocked by the safety guard
  - pharmacist corrections
  - summaries the patient edited
  - «model down» moments
  - Each item shows the conversation **without the patient's name or phone** (age, sex and pharmacy only). The admin marks it reviewed, with a note.
- **Knowledge base («قاعدة المعرفة»)**: short notes the admin curates, usually from a correction («الأطفال تحت سنتين: لا تسأل عن الجرعة، حوّل للصيدلي»). Each note has tags and on/off; every change is logged. The assistant receives the notes that match the conversation (PostgreSQL full-text search, no vector database, no new service). **Never automatic training.**
- **Settings**: see the model in use and whether it answers, the emergency numbers, the CORS origins (read-only; changed in the server's settings).

### A2. Owner's additions (2026-09-26): the admin panel is for the platform owner (the developer)
- **Pharmacy performance for rewards**: per pharmacy and month:
  - cases received / answered / left unanswered
  - median and 90th-percentile first response time
  - share answered within 10 minutes
  - orders prepared and rejected
  - urgent cases answered in time
  - A ranking the owner can use to reward pharmacies (the rewards themselves are decided outside the app).
- **Full control of each pharmacy, including when a contract ends**:
  - «تعليق» (suspend): at once, Doaya online stops for it (no cases, no orders, hidden from patients). Its own server learns this at its next connection and shows the owner why.
  - «إيقاف النظام» (stop the pharmacy's system): its server, at its next connection, locks selling and stock changes and shows «انتهى الاشتراك، تواصل مع دوايا». **Export of the pharmacy's own data (sales, debts, stock) always stays open**: their records are theirs (and needed by law).
  - A pharmacy that never connects again can't be reached this way; the fallback is a **licence that needs renewing**. The pharmacy server keeps working offline up to N days (proposal: 30) after its last contact with Doaya online, then asks to connect once. Selling is never blocked in the middle of a day; it locks at the next start.
  - «إلغاء» (remove): uninstalling on site. The admin marks it removed and its key stops working.
  - Every one of these actions asks for confirmation and is logged (who, when, why).

### A3. Owner's answers (2026-09-26, after the design page)
- **Design**: all three directions from the «لوحة مالك دوايا» page, and the owner switches between them in the panel:
  - «غرفة القيادة» (dark console)
  - «الدفتر» (light, navy side menu)
  - «من عيلة دوايا» (Doaya green, Amiri headings)
  - Built as three looks on the existing `DoayaLook` system, so no new colour code and no new fonts (Readex Pro + Amiri, bundled).
- **Always connected, but the pharmacy's business stays private.** The owner sees *whether the pharmacy is running*, never its stock, medicines, sales, profits or debts.
  - **Heartbeat** every 10 minutes from each pharmacy's server (with the shelf publish). It sends only:
    - app and server version
    - how many devices, and when each last synced
    - last backup time
    - sync errors
  - The panel shows each pharmacy as connected / not seen for X.
  - The heartbeat's reply carries the **control state** (active / suspended / stopped / removed) and the licence date.
  - **Monthly health check** (the "full access once a month" the owner asked for):
    - The pharmacy's own server runs it over *all* its data, on its own PC.
    - It sends up **only the results** («تمام» / «تنبيه» / «مشكلة» per check, with a count at most), never the data. Checks:
      - backups ran
      - every device synced
      - ledgers consistent (no stock below zero, every event has device/employee/time)
      - open shifts left unclosed
      - expired items still marked for sale (count only)
      - disk space
      - the server version is supported
    - The owner can ask for a check now from the panel; it runs at the next heartbeat.
    - Deeper remote access (seeing screens or data) is **not built**. If ever needed, it would need the pharmacy owner's approval on their screen each time (proposal, not in this phase).
- **Licence**: 30 days without contact by default, changeable per pharmacy from the panel. «إيقاف النظام» means read-only screens + data export (the recommendation; the owner can change it).

### B. Admin app (`apps/admin`, Flutter web, `--no-web-resources-cdn`)
- Sign-in, then a side menu as in the layout: نظرة عامة، الصيدليات، المرضى، مراجعة المحادثات (with a badge)، قاعدة المعرفة، الإعدادات. «المدفوعات» is shown as off for now.
- Desktop-first, solid surfaces (no blur), usable on a tablet.

### Steps (tests first; a commit after each; **stop for review at the end**)
1. Server: admin accounts, overview, pharmacies and their actions; tests (including: a pharmacy or patient token can't reach any admin endpoint).
2. Server: review queue + knowledge base + the assistant using the notes; tests (a note reaches the prompt only when it matches; a disabled note never does).
3. Admin app: skeleton, sign-in, overview, pharmacies.
4. Admin app: review queue and knowledge base, settings.
5. Real run with screenshots, docs → **review**.

### Done (2026-09-26)
- **Server**:
  - Admin accounts: `app.cli create-admin`, with long sessions like the patients' and a sign-in limiter. No other token reaches `/admin/*`, and an admin token reaches nothing else (tested).
  - Overview.
  - Pharmacies:
    - add a pharmacy (its server key is shown once)
    - approve / suspend / resume / stop / remove
    - list / hide
    - new key
    - licence days
    - health check now
    - Each action needs a reason where it matters, and is logged with who, when and why.
  - First response time is recorded on the pharmacist's first action.
  - Performance per month for rewards:
    - answered, median, P90, share within 10 minutes
    - urgent cases answered in time, orders
    - tiers: gold (answered ≥95% and ≥90% within 10 minutes) and silver (≥90% and ≥75%)
    - fewer than 10 cases: not ranked
- **Control and heartbeat**:
  - Each pharmacy's server reports with every shelf publish (every 10 minutes). The report is technical only: version, devices, backups, errors, disk. A test proves no product, price, sale or customer leaves the pharmacy.
  - The answer carries the owner's control and the licence. It is kept in `control.json`, and the devices ask `GET /control`.
  - The pharmacy app keeps the answer after each sync and reads it once at start. When stopped, removed, or the licence has expired, these close:
    - selling
    - receiving stock
    - stocktake
    - purchases
    - the till
  - Reports, inventory, debts, backups and export stay open.
  - It never locks in the middle of a day. A reminder shows 5 days before the licence runs out. Unlinking from Doaya online doesn't lift a lock.
- **Monthly health check**: runs on the pharmacy's PC over all its data and sends only verdicts and counts:
  - backups
  - devices synced
  - stock below zero
  - expired items still for sale
  - incomplete ledger events
  - shifts left open
  - disk space
- **Review queue**:
  - Covers red flags, guard blocks, corrections, edited summaries and model-down moments.
  - Shown with age, sex and pharmacy only (tested: no patient name or phone).
  - Items are marked reviewed with a note, and can become a knowledge note.
- **Knowledge base**:
  - Notes with tags and on/off. Every change is logged.
  - A note that states a dose is refused.
  - The assistant gets up to 3 enabled notes whose tags the patient mentioned. Spelling is folded and stems are allowed. The notes used are logged with the reply.
  - A «جرّب» box shows which notes a sentence would bring.
- **Admin app** (`apps/admin`, Flutter web, built with `--no-web-resources-cdn`):
  - Screens: sign-in, overview (with the response-time chart and the pharmacies needing attention), pharmacies with the detail and the actions, performance, review, knowledge, settings (with a model check).
  - **The three designs** switch from the top bar and are kept in the browser. No blur.
- **Found by the real run and fixed**:
  - Text fields vanished in the flat style (no edge on a card of the same colour). Fields now always show their edge (`doaya_ui`, all apps).
  - Review details showed raw English keys. They now show in words.
  - The review button stretched across the banner.
- Screenshots: `docs/screenshots/phase4/` (the three designs on the overview, a pharmacy with health warnings, a suspended pharmacy, performance, review, knowledge, settings, sign-in).
- Tests: server 231, pharmacy 108, patient 28, admin 11, `doaya_ui` 30, core 95.

### Questions for the owner
1. Themes: the preview page's choices. (answered: approved, with more colours and styles)
2. Themes: «تصميمي» for everyone? (answered: the look is for everyone)
3. Admin: one admin (the owner) for now; more can be added from the server's command line. (answered)
4. Admin: reviewing shows no patient name/phone (age, sex, pharmacy only). (answered: approved)
6. Stopping a pharmacy: licence days and read-only vs export. (answered in A3: 30 days, per pharmacy; read-only + export)
5. Order: themes first, then Phase 4. (answered: yes)
