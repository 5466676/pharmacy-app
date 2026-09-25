# Decisions

One entry per non-obvious choice: date · decision · why.

## 2026-09-25 · Dart pub workspace at the repo root
A root `pubspec.yaml` declares `workspace:` members. One `flutter pub get` resolves every package with a single shared lockfile, so all apps use identical dependency versions. Built into Dart ≥ 3.6, so no extra tool such as melos.

## 2026-09-25 · Component gallery lives in `packages/doaya_ui/example`
The gallery is a dev tool for the design system, not a product app, so it sits next to the package it demonstrates. It runs on web, Linux and Windows.

## 2026-09-25 · Readex Pro shipped as static weights (300/400/500/600)
Upstream ships only a variable font (`wght` + `HEXP` axes). Flutter picks a font asset by the `weight:` declared in pubspec, and a single variable file doesn't reliably render intermediate weights on every platform. We cut static instances at HEXP=0 with `fonttools varLib.instancer`. This is a one-off build step with nothing added at runtime. Amiri Bold is used as-is. OFL licenses are bundled next to the fonts.

## 2026-09-25 · `flutter_localizations` + `intl` for ARB files
The spec requires ARB localization. Flutter's `gen-l10n` needs `flutter_localizations` (part of the SDK) and `intl`. The spec's localization requirement implies both, so they are the only additions beyond the listed stack.

## 2026-09-25 · Arabic-Indic digits via our own formatter
In `intl`, the `ar` locale formats with Latin digits, and the digit set depends on the locale variant. `formatArabicNumber` / `toArabicDigits` in `doaya_ui` format first, then map to ٠–٩ with the Arabic decimal separator (٫) and group separator (٬). This gives predictable output on every platform and is unit-tested.

## 2026-09-25 · Two theme modes: `glass` and `solid`
`DoayaTheme.glass()` (patient/admin/pharmacy mobile) and `DoayaTheme.solid()` (pharmacy desktop) expose the same `DoayaTokens` ThemeExtension. `GlassSurface` reads `tokens.surfaceStyle`. In solid mode it maps glassFill → `surface`, glassFillStrong → `surfaceRaised`, borders → `border` and never builds a `BackdropFilter`, whatever the widget asks for. Screens are written once and the desktop stays blur-free automatically.

## 2026-09-25 · Background blobs drawn with radial gradients, not blur filters
The mockup uses `filter: blur(80px)` circles. A `RadialGradient` fading to transparent gives the same look at almost no cost, which matters on old counter laptops. Leaf shapes use a small `MaskFilter.blur` inside a `CustomPainter`. The whole background sits in a `RepaintBoundary`.

## 2026-09-25 · Material Icons (rounded) instead of custom SVG icons for now
The mockups use Feather-style line icons. Loading SVGs would need `flutter_svg` (a new dependency). Material's rounded outlined icons are close enough for Phase 0. All icon choices live in `DoayaIcons`, so swapping to a custom icon font later is a one-file change.

## 2026-09-25 · Components take strings as parameters
`doaya_ui` components contain no user-facing text. Every label comes from the calling app's ARB file, which keeps the design system free of copy and lets each app own its wording.
