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

### Open questions for review
- `design/*.html` reference a `support.js` that wasn't in the zip. The files still render (static markup); only the preview-harness script is missing.
- The icon set is Material Rounded for now (see DECISIONS). Do you want a custom line-icon set later (needs `flutter_svg` or an icon font)?

## Phase 1 — Pharmacy core (offline) · not started
Plan will be written here and submitted for approval before starting.
