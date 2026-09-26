import 'dart:math' as math;
import 'dart:ui';

/// How surfaces are drawn.
enum DoayaStyle {
  /// Translucent and blurred (today's Doaya).
  glass,

  /// Solid colours, no shadows.
  flat,

  /// Rounder, soft shadows.
  soft,

  /// Minimal: thin frames, small corners.
  outline,

  /// For weak eyesight and sunlight: 7:1 text, thick borders.
  contrast,
}

/// Night, day, pure black, or whatever the device says.
enum DoayaMode { dark, light, black, auto }

enum DoayaHeadingFont { amiri, readex }

/// A ready palette: the main colour and a night and a day background.
/// None has a red main colour: red means danger in Doaya.
class DoayaPaletteSpec {
  const DoayaPaletteSpec(this.id, this.main, this.dark, this.light);

  final String id;
  final Color main;
  final Color dark;
  final Color light;

  static const green = DoayaPaletteSpec('green', Color(0xFFC9DEAE), Color(0xFF1B3F2B), Color(0xFFEAF0E6));

  static const all = [
    green,
    DoayaPaletteSpec('navy', Color(0xFF9FDCD4), Color(0xFF152A45), Color(0xFFE8EFF6)),
    DoayaPaletteSpec('wine', Color(0xFFEBCB8B), Color(0xFF35151F), Color(0xFFF6EDEE)),
    DoayaPaletteSpec('violet', Color(0xFFC3B1F5), Color(0xFF231B3D), Color(0xFFF0EDF9)),
    DoayaPaletteSpec('sky', Color(0xFF8CC8F5), Color(0xFF0F2A3F), Color(0xFFEAF3FA)),
    DoayaPaletteSpec('rose', Color(0xFFF2B6C6), Color(0xFF3A1A26), Color(0xFFFBEFF3)),
    DoayaPaletteSpec('amber', Color(0xFFF2B366), Color(0xFF2E2116), Color(0xFFFAF1E6)),
    DoayaPaletteSpec('olive', Color(0xFFD6D38A), Color(0xFF2A2C18), Color(0xFFF2F2E4)),
    DoayaPaletteSpec('mint', Color(0xFF8FE0B5), Color(0xFF11302A), Color(0xFFE9F6F0)),
    DoayaPaletteSpec('sand', Color(0xFFD8B48A), Color(0xFF2F271F), Color(0xFFF5EFE7)),
    DoayaPaletteSpec('char', Color(0xFFDADADA), Color(0xFF1E1F22), Color(0xFFF1F1F2)),
  ];

  static DoayaPaletteSpec byId(String id) =>
      all.firstWhere((p) => p.id == id, orElse: () => green);
}

/// Everything the user picks in «المظهر». Kept per device, never synced.
class DoayaLook {
  const DoayaLook({
    this.style = DoayaStyle.glass,
    this.mode = DoayaMode.dark,
    this.palette = 'green',
    this.customMain = const Color(0xFFE0A458),
    this.customDark = const Color(0xFF2B2F3A),
    this.customLight = const Color(0xFFF3EEE6),
    this.radius = 1,
    this.blur = 18,
    this.textScale = 1,
    this.density = 1,
    this.headingFont = DoayaHeadingFont.amiri,
  });

  /// `custom` = the user's own colours ([customMain], [customDark],
  /// [customLight]); otherwise a [DoayaPaletteSpec] id.
  static const custom = 'custom';

  final DoayaStyle style;
  final DoayaMode mode;
  final String palette;
  final Color customMain;
  final Color customDark;
  final Color customLight;

  /// Corner roundness, 0 (sharp) … 2 (round). 1 = the design's own radii.
  final double radius;

  /// Blur sigma for the glass style.
  final double blur;

  /// 0.92 · 1 · 1.15 · 1.3.
  final double textScale;

  /// 1 = comfortable, 0.72 = compact (spacing only).
  final double density;
  final DoayaHeadingFont headingFont;

  static const textScales = [0.92, 1.0, 1.15, 1.3];
  static const densities = [1.0, 0.72];

  /// Night, day or black, with «تلقائي» resolved against the device.
  DoayaMode resolvedMode(Brightness platform) => mode == DoayaMode.auto
      ? (platform == Brightness.light ? DoayaMode.light : DoayaMode.dark)
      : mode;

  DoayaLook copyWith({
    DoayaStyle? style,
    DoayaMode? mode,
    String? palette,
    Color? customMain,
    Color? customDark,
    Color? customLight,
    double? radius,
    double? blur,
    double? textScale,
    double? density,
    DoayaHeadingFont? headingFont,
  }) => DoayaLook(
    style: style ?? this.style,
    mode: mode ?? this.mode,
    palette: palette ?? this.palette,
    customMain: customMain ?? this.customMain,
    customDark: customDark ?? this.customDark,
    customLight: customLight ?? this.customLight,
    radius: radius ?? this.radius,
    blur: blur ?? this.blur,
    textScale: textScale ?? this.textScale,
    density: density ?? this.density,
    headingFont: headingFont ?? this.headingFont,
  );

  Map<String, Object?> toJson() => {
    'style': style.name,
    'mode': mode.name,
    'palette': palette,
    'custom_main': customMain.toARGB32(),
    'custom_dark': customDark.toARGB32(),
    'custom_light': customLight.toARGB32(),
    'radius': radius,
    'blur': blur,
    'text_scale': textScale,
    'density': density,
    'heading_font': headingFont.name,
  };

  /// Unknown or broken values fall back to the defaults.
  factory DoayaLook.fromJson(Map<String, Object?> j) {
    const d = DoayaLook();
    T pick<T extends Enum>(List<T> values, Object? name, T fallback) =>
        values.where((v) => v.name == name).firstOrNull ?? fallback;
    Color color(Object? v, Color fallback) => v is int ? Color(v) : fallback;
    double number(Object? v, double fallback, double lo, double hi) =>
        v is num ? v.toDouble().clamp(lo, hi) : fallback;
    return DoayaLook(
      style: pick(DoayaStyle.values, j['style'], d.style),
      mode: pick(DoayaMode.values, j['mode'], d.mode),
      palette: j['palette'] is String ? j['palette']! as String : d.palette,
      customMain: color(j['custom_main'], d.customMain),
      customDark: color(j['custom_dark'], d.customDark),
      customLight: color(j['custom_light'], d.customLight),
      radius: number(j['radius'], d.radius, 0, 2),
      blur: number(j['blur'], d.blur, 0, 30),
      textScale: number(j['text_scale'], d.textScale, 0.8, 1.4),
      density: number(j['density'], d.density, 0.6, 1),
      headingFont: pick(DoayaHeadingFont.values, j['heading_font'], d.headingFont),
    );
  }

  @override
  bool operator ==(Object other) =>
      other is DoayaLook && _eq(toJson(), other.toJson());

  @override
  int get hashCode => Object.hashAll(toJson().values);

  static bool _eq(Map<String, Object?> a, Map<String, Object?> b) =>
      a.length == b.length && a.keys.every((k) => a[k] == b[k]);
}

// ─── Colour maths ───────────────────────────────────────────────────────────

double _lin(double c) => c <= 0.03928 ? c / 12.92 : math.pow((c + 0.055) / 1.055, 2.4).toDouble();

/// WCAG relative luminance.
double luminance(Color c) => 0.2126 * _lin(c.r) + 0.7152 * _lin(c.g) + 0.0722 * _lin(c.b);

/// WCAG contrast ratio (1 … 21), alpha ignored.
double contrastRatio(Color a, Color b) {
  final x = luminance(a), y = luminance(b);
  return (math.max(x, y) + 0.05) / (math.min(x, y) + 0.05);
}

Color _mix(Color a, Color b, double t) => Color.lerp(a.withAlpha(255), b.withAlpha(255), t)!;

Color _alpha(Color c, double a) => c.withValues(alpha: a);

const _white = Color(0xFFFFFFFF);
const _black = Color(0xFF000000);

/// [fg] moved toward white or black until it reads on [bg] at [target].
/// Returns the colour and whether it had to move.
(Color, bool) ensureContrast(Color fg, Color bg, double target) {
  final towards = luminance(bg) > 0.35 ? _black : _white;
  var c = fg.withAlpha(255);
  var steps = 0;
  while (contrastRatio(c, bg) < target && steps < 80) {
    c = _mix(c, towards, 0.07);
    steps++;
  }
  return (c, steps > 0);
}

// ─── The palette every widget reads ────────────────────────────────────────

/// Every colour Doaya draws with, for one [DoayaLook]. `DoayaColors.*`
/// read the current one. Safety colours (danger, warning) keep their
/// meaning in every look.
class DoayaPalette {
  const DoayaPalette({
    required this.brightness,
    required this.bgTop,
    required this.bgMid,
    required this.bgBottom,
    required this.blobLight,
    required this.blobDark,
    required this.leafFillA,
    required this.leafVeinA,
    required this.leafFillB,
    required this.leafVeinB,
    required this.photoScrim,
    required this.glassFill,
    required this.glassFillStrong,
    required this.glassBorder,
    required this.glassBorderStrong,
    required this.glassHighlight,
    required this.glassHighlightStrong,
    required this.surface,
    required this.surfaceRaised,
    required this.border,
    required this.sageTop,
    required this.sageBottom,
    required this.sageHighlight,
    required this.onSage,
    required this.sagePressed,
    required this.sageHover,
    required this.accent,
    required this.price,
    required this.textPrimary,
    required this.textSecondary,
    required this.textBody,
    required this.selectedTileFill,
    required this.selectedTileBorder,
    required this.accentSoftFill,
    required this.accentSoftBorder,
    required this.navActiveFill,
    required this.warningFill,
    required this.warningBorder,
    required this.warningText,
    required this.warningIcon,
    required this.dangerFill,
    required this.dangerBorder,
    required this.dangerText,
    required this.successDot,
    required this.imageWell,
    required this.imageWellBorder,
    required this.divider,
    required this.subtleFill,
    required this.dotInactive,
    required this.shadow,
    required this.shadowStrong,
    required this.shadowSolid,
    required this.scrim,
    this.accentAdjusted = false,
  });

  final Brightness brightness;
  final Color bgTop, bgMid, bgBottom, blobLight, blobDark;
  final Color leafFillA, leafVeinA, leafFillB, leafVeinB, photoScrim;
  final Color glassFill, glassFillStrong, glassBorder, glassBorderStrong;
  final Color glassHighlight, glassHighlightStrong;
  final Color surface, surfaceRaised, border;
  final Color sageTop, sageBottom, sageHighlight, onSage, sagePressed, sageHover;
  final Color accent, price, textPrimary, textSecondary, textBody;
  final Color selectedTileFill, selectedTileBorder, accentSoftFill, accentSoftBorder, navActiveFill;
  final Color warningFill, warningBorder, warningText, warningIcon;
  final Color dangerFill, dangerBorder, dangerText, successDot;
  final Color imageWell, imageWellBorder, divider, subtleFill, dotInactive;
  final Color shadow, shadowStrong, shadowSolid, scrim;

  /// The chosen main colour had to be lightened/darkened to stay readable.
  final bool accentAdjusted;

  static const transparent = Color(0x00000000);

  /// Doaya as designed (green, night): the look nobody has to choose.
  static const classic = DoayaPalette(
    brightness: Brightness.dark,
    bgTop: Color(0xFF285439),
    bgMid: Color(0xFF1B3F2B),
    bgBottom: Color(0xFF153422),
    blobLight: Color(0xFF3F7153),
    blobDark: Color(0xFF2F5A3F),
    leafFillA: Color(0xFF29573C),
    leafVeinA: Color(0xFF50865F),
    leafFillB: Color(0xFF26523A),
    leafVeinB: Color(0xFF4A8057),
    photoScrim: Color.fromRGBO(21, 52, 34, 0.55),
    glassFill: Color.fromRGBO(236, 242, 234, 0.09),
    glassFillStrong: Color.fromRGBO(236, 242, 234, 0.13),
    glassBorder: Color.fromRGBO(236, 242, 234, 0.20),
    glassBorderStrong: Color.fromRGBO(236, 242, 234, 0.26),
    glassHighlight: Color.fromRGBO(255, 255, 255, 0.12),
    glassHighlightStrong: Color.fromRGBO(255, 255, 255, 0.16),
    surface: Color(0xFF224531),
    surfaceRaised: Color(0xFF274C38),
    border: Color(0xFF345E45),
    sageTop: Color(0xFFDCE8C8),
    sageBottom: Color(0xFFA9C191),
    sageHighlight: Color.fromRGBO(255, 255, 255, 0.5),
    onSage: Color(0xFF1B3024),
    sagePressed: Color.fromRGBO(27, 48, 36, 0.12),
    sageHover: Color.fromRGBO(27, 48, 36, 0.06),
    accent: Color(0xFFC9DEAE),
    price: Color(0xFFC9E0A8),
    textPrimary: Color(0xFFEEF3EC),
    textSecondary: Color(0xFFC3CEC2),
    textBody: Color(0xFFD5DFD3),
    selectedTileFill: Color.fromRGBO(201, 222, 174, 0.18),
    selectedTileBorder: Color.fromRGBO(201, 222, 174, 0.6),
    accentSoftFill: Color.fromRGBO(201, 222, 174, 0.14),
    accentSoftBorder: Color.fromRGBO(201, 222, 174, 0.3),
    navActiveFill: Color.fromRGBO(201, 222, 174, 0.22),
    warningFill: Color.fromRGBO(242, 196, 120, 0.14),
    warningBorder: Color.fromRGBO(242, 196, 120, 0.35),
    warningText: Color(0xFFF5DDB0),
    warningIcon: Color(0xFFF2C478),
    dangerFill: Color.fromRGBO(240, 120, 110, 0.16),
    dangerBorder: Color.fromRGBO(240, 120, 110, 0.40),
    dangerText: Color(0xFFF6B7B0),
    successDot: Color(0xFFA8D98A),
    imageWell: Color.fromRGBO(255, 255, 255, 0.06),
    imageWellBorder: Color.fromRGBO(255, 255, 255, 0.10),
    divider: Color.fromRGBO(255, 255, 255, 0.12),
    subtleFill: Color.fromRGBO(255, 255, 255, 0.08),
    dotInactive: Color.fromRGBO(255, 255, 255, 0.3),
    shadow: Color.fromRGBO(0, 0, 0, 0.18),
    shadowStrong: Color.fromRGBO(0, 0, 0, 0.25),
    shadowSolid: Color.fromRGBO(0, 0, 0, 0.14),
    scrim: Color.fromRGBO(10, 26, 17, 0.6),
  );

  /// The palette for [look] (with «تلقائي» resolved against [platform]).
  factory DoayaPalette.of(DoayaLook look, {Brightness platform = Brightness.dark}) {
    final mode = look.resolvedMode(platform);
    final isCustom = look.palette == DoayaLook.custom;
    final spec = DoayaPaletteSpec.byId(look.palette);
    final hi = look.style == DoayaStyle.contrast;
    if (!isCustom && spec.id == 'green' && mode == DoayaMode.dark && !hi) return classic;

    final light = mode == DoayaMode.light;
    final black = mode == DoayaMode.black;
    final main = isCustom ? look.customMain : spec.main;
    var back = black
        ? _black
        : light
        ? (isCustom ? look.customLight : spec.light)
        : (isCustom ? look.customDark : spec.dark);
    // A night background chosen too bright is darkened; a day one too dark, lightened.
    for (var i = 0; !light && !black && luminance(back) > 0.08 && i < 40; i++) {
      back = _mix(back, _black, 0.1);
    }
    for (var i = 0; light && luminance(back) < 0.72 && i < 40; i++) {
      back = _mix(back, _white, 0.1);
    }
    // High contrast: a deeper night / a paler day, so text can reach 12:1.
    if (hi && !light && !black) back = _mix(back, _black, 0.45);
    if (hi && light) back = _mix(back, _white, 0.5);

    final target = hi ? 7.0 : 4.5;
    final top = black ? _black : light ? _mix(back, _white, .4) : _mix(back, _white, .10);
    final bottom = black ? _black : light ? _mix(back, _black, .05) : _mix(back, _black, .25);
    final (text, _) = ensureContrast(
      light ? _mix(back, _black, hi ? .97 : .88) : _mix(back, _white, hi ? 1 : .93),
      back,
      hi ? 12 : 7,
    );
    final (text2, _) = ensureContrast(_mix(text, back, hi ? .12 : .28), back, target);
    final (textBody, _) = ensureContrast(_mix(text, back, .15), back, target);
    final (accent, adjusted) = ensureContrast(main, back, target);
    // The button: built from the readable main colour, then the text on it
    // (white or dark, whichever reads better), then nudged until it reads.
    const dark = Color(0xFF141414);
    var accentOn = accent;
    var sageTop = light ? _mix(accent, _white, .06) : _mix(accent, _white, .42);
    var sageBottom = light ? _mix(accent, _black, .12) : accent;
    double whiteScore() => math.min(contrastRatio(_white, sageTop), contrastRatio(_white, accentOn));
    double darkScore() => math.min(contrastRatio(dark, sageBottom), contrastRatio(dark, accentOn));
    final onWhite = whiteScore() >= darkScore();
    final away = onWhite ? _black : _white;
    for (var i = 0; i < 60 && (onWhite ? whiteScore() : darkScore()) < 4.5; i++) {
      sageTop = _mix(sageTop, away, .07);
      sageBottom = _mix(sageBottom, away, .07);
      accentOn = _mix(accentOn, away, .07);
    }
    final onSage = onWhite ? _white : _mix(back, _black, .75);
    final surface = black ? const Color(0xFF0B0B0B) : light ? _white : _mix(back, _white, .06);
    final raised = black ? const Color(0xFF141414) : light ? _mix(back, _white, .55) : _mix(back, _white, .11);
    final glassBase = light ? _white : text;
    final ink = light ? text : _white;

    return DoayaPalette(
      brightness: light ? Brightness.light : Brightness.dark,
      bgTop: top,
      bgMid: back,
      bgBottom: bottom,
      blobLight: light ? _white : black ? _black : _mix(back, _white, .22),
      blobDark: light ? _mix(back, _black, .08) : black ? _black : _mix(back, _white, .14),
      leafFillA: light ? _mix(back, _black, .06) : _mix(back, _white, .07),
      leafVeinA: light ? _mix(back, _black, .14) : _mix(back, _white, .25),
      leafFillB: light ? _mix(back, _black, .04) : _mix(back, _white, .05),
      leafVeinB: light ? _mix(back, _black, .12) : _mix(back, _white, .22),
      photoScrim: _alpha(back, .55),
      glassFill: light ? _alpha(_white, .62) : _alpha(glassBase, black ? .07 : .09),
      glassFillStrong: light ? _alpha(_white, .8) : _alpha(glassBase, black ? .11 : .13),
      glassBorder: light ? _alpha(text, .12) : _alpha(glassBase, .20),
      glassBorderStrong: light ? _alpha(text, .16) : _alpha(glassBase, .26),
      glassHighlight: _alpha(_white, light ? .9 : .12),
      glassHighlightStrong: _alpha(_white, light ? .95 : .16),
      surface: surface,
      surfaceRaised: raised,
      border: light ? _mix(back, _black, .14) : black ? const Color(0xFF2A2A2A) : _mix(back, _white, .2),
      sageTop: sageTop,
      sageBottom: sageBottom,
      sageHighlight: _alpha(_white, light ? .25 : .5),
      onSage: onSage,
      sagePressed: _alpha(onSage, .12),
      sageHover: _alpha(onSage, .06),
      accent: accentOn,
      price: accentOn,
      textPrimary: text,
      textSecondary: text2,
      textBody: textBody,
      selectedTileFill: _alpha(accent, light ? .12 : .18),
      selectedTileBorder: _alpha(accent, .6),
      accentSoftFill: _alpha(accent, light ? .10 : .14),
      accentSoftBorder: _alpha(accent, .3),
      navActiveFill: _alpha(accent, .22),
      // Safety: the same meaning everywhere, darker on a light background.
      warningFill: light ? const Color.fromRGBO(214, 150, 30, 0.14) : classic.warningFill,
      warningBorder: light ? const Color.fromRGBO(170, 110, 10, 0.45) : classic.warningBorder,
      warningText: light ? const Color(0xFF6E4600) : classic.warningText,
      warningIcon: light ? const Color(0xFF9A6200) : classic.warningIcon,
      dangerFill: light ? const Color.fromRGBO(200, 50, 40, 0.10) : classic.dangerFill,
      dangerBorder: light ? const Color.fromRGBO(160, 35, 25, 0.45) : classic.dangerBorder,
      dangerText: light ? const Color(0xFF8E1F14) : classic.dangerText,
      successDot: light ? const Color(0xFF2E8B45) : classic.successDot,
      imageWell: _alpha(ink, light ? .05 : .06),
      imageWellBorder: _alpha(ink, light ? .08 : .10),
      divider: _alpha(ink, light ? .10 : .12),
      subtleFill: _alpha(ink, light ? .05 : .08),
      dotInactive: _alpha(ink, .3),
      shadow: _alpha(_black, light ? .08 : .18),
      shadowStrong: _alpha(_black, light ? .12 : .25),
      shadowSolid: _alpha(_black, light ? .08 : .14),
      scrim: _alpha(light ? _mix(back, _black, .6) : _mix(back, _black, .5), .6),
      accentAdjusted: adjusted,
    );
  }
}
