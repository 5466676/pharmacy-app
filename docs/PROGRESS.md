# Progress

## Phase 0 — Foundation · ✅ ready for review

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

## Phase 1 — Pharmacy core (offline) · not started
Plan will be written here and submitted for approval before starting.
