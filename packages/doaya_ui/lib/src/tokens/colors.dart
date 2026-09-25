import 'dart:ui';

/// Every color in Doaya. Widgets never use a color literal; they read from here
/// (directly for mode-independent colors, or via `DoayaTokens` for surfaces).
abstract final class DoayaColors {
  // Background gradient.
  static const bgTop = Color(0xFF285439);
  static const bgMid = Color(0xFF1B3F2B);
  static const bgBottom = Color(0xFF153422);

  // Background decoration (blobs + leaves).
  static const blobLight = Color(0xFF3F7153);
  static const blobDark = Color(0xFF2F5A3F);
  static const leafFillA = Color(0xFF29573C);
  static const leafVeinA = Color(0xFF50865F);
  static const leafFillB = Color(0xFF26523A);
  static const leafVeinB = Color(0xFF4A8057);
  static const photoScrim = Color.fromRGBO(21, 52, 34, 0.55);

  // Glass.
  static const glassFill = Color.fromRGBO(236, 242, 234, 0.09);
  static const glassFillStrong = Color.fromRGBO(236, 242, 234, 0.13);
  static const glassBorder = Color.fromRGBO(236, 242, 234, 0.20);
  static const glassBorderStrong = Color.fromRGBO(236, 242, 234, 0.26);
  static const glassHighlight = Color.fromRGBO(255, 255, 255, 0.12);
  static const glassHighlightStrong = Color.fromRGBO(255, 255, 255, 0.16);

  // Solid variants (pharmacy desktop, long lists).
  static const surface = Color(0xFF224531);
  static const surfaceRaised = Color(0xFF274C38);
  static const border = Color(0xFF345E45);

  // Sage (primary action).
  static const sageTop = Color(0xFFDCE8C8);
  static const sageBottom = Color(0xFFA9C191);
  static const sageHighlight = Color.fromRGBO(255, 255, 255, 0.5);
  static const onSage = Color(0xFF1B3024);
  static const sagePressed = Color.fromRGBO(27, 48, 36, 0.12);
  static const sageHover = Color.fromRGBO(27, 48, 36, 0.06);

  // Accent & text.
  static const accent = Color(0xFFC9DEAE);
  static const price = Color(0xFFC9E0A8);
  static const textPrimary = Color(0xFFEEF3EC);
  static const textSecondary = Color(0xFFC3CEC2);
  static const textBody = Color(0xFFD5DFD3);

  // Selection.
  static const selectedTileFill = Color.fromRGBO(201, 222, 174, 0.18);
  static const selectedTileBorder = Color.fromRGBO(201, 222, 174, 0.6);
  static const accentSoftFill = Color.fromRGBO(201, 222, 174, 0.14);
  static const accentSoftBorder = Color.fromRGBO(201, 222, 174, 0.3);
  static const navActiveFill = Color.fromRGBO(201, 222, 174, 0.22);

  // Status.
  static const warningFill = Color.fromRGBO(242, 196, 120, 0.14);
  static const warningBorder = Color.fromRGBO(242, 196, 120, 0.35);
  static const warningText = Color(0xFFF5DDB0);
  static const warningIcon = Color(0xFFF2C478);
  static const dangerFill = Color.fromRGBO(240, 120, 110, 0.16);
  static const dangerBorder = Color.fromRGBO(240, 120, 110, 0.40);
  static const dangerText = Color(0xFFF6B7B0);
  static const successDot = Color(0xFFA8D98A);

  // Misc neutrals.
  static const imageWell = Color.fromRGBO(255, 255, 255, 0.06);
  static const imageWellBorder = Color.fromRGBO(255, 255, 255, 0.10);
  static const divider = Color.fromRGBO(255, 255, 255, 0.12);
  static const subtleFill = Color.fromRGBO(255, 255, 255, 0.08);
  static const dotInactive = Color.fromRGBO(255, 255, 255, 0.3);
  static const shadow = Color.fromRGBO(0, 0, 0, 0.18);
  static const shadowStrong = Color.fromRGBO(0, 0, 0, 0.25);
  static const shadowSolid = Color.fromRGBO(0, 0, 0, 0.14);
  static const scrim = Color.fromRGBO(10, 26, 17, 0.6);
  static const transparent = Color(0x00000000);
}
