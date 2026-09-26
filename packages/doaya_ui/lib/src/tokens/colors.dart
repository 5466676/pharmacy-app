import 'dart:ui';

import '../theme/doaya_appearance.dart';

/// Every color in Doaya. Widgets never use a color literal; they read from here.
/// The values follow the user's «المظهر» choice (`DoayaAppearance`); the
/// default look is Doaya's own green night.
abstract final class DoayaColors {
  static Color get bgTop => DoayaAppearance.palette.bgTop;
  static Color get bgMid => DoayaAppearance.palette.bgMid;
  static Color get bgBottom => DoayaAppearance.palette.bgBottom;
  static Color get blobLight => DoayaAppearance.palette.blobLight;
  static Color get blobDark => DoayaAppearance.palette.blobDark;
  static Color get leafFillA => DoayaAppearance.palette.leafFillA;
  static Color get leafVeinA => DoayaAppearance.palette.leafVeinA;
  static Color get leafFillB => DoayaAppearance.palette.leafFillB;
  static Color get leafVeinB => DoayaAppearance.palette.leafVeinB;
  static Color get photoScrim => DoayaAppearance.palette.photoScrim;
  static Color get glassFill => DoayaAppearance.palette.glassFill;
  static Color get glassFillStrong => DoayaAppearance.palette.glassFillStrong;
  static Color get glassBorder => DoayaAppearance.palette.glassBorder;
  static Color get glassBorderStrong => DoayaAppearance.palette.glassBorderStrong;
  static Color get glassHighlight => DoayaAppearance.palette.glassHighlight;
  static Color get glassHighlightStrong => DoayaAppearance.palette.glassHighlightStrong;
  static Color get surface => DoayaAppearance.palette.surface;
  static Color get surfaceRaised => DoayaAppearance.palette.surfaceRaised;
  static Color get border => DoayaAppearance.palette.border;
  static Color get sageTop => DoayaAppearance.palette.sageTop;
  static Color get sageBottom => DoayaAppearance.palette.sageBottom;
  static Color get sageHighlight => DoayaAppearance.palette.sageHighlight;
  static Color get onSage => DoayaAppearance.palette.onSage;
  static Color get sagePressed => DoayaAppearance.palette.sagePressed;
  static Color get sageHover => DoayaAppearance.palette.sageHover;
  static Color get accent => DoayaAppearance.palette.accent;
  static Color get price => DoayaAppearance.palette.price;
  static Color get textPrimary => DoayaAppearance.palette.textPrimary;
  static Color get textSecondary => DoayaAppearance.palette.textSecondary;
  static Color get textBody => DoayaAppearance.palette.textBody;
  static Color get selectedTileFill => DoayaAppearance.palette.selectedTileFill;
  static Color get selectedTileBorder => DoayaAppearance.palette.selectedTileBorder;
  static Color get accentSoftFill => DoayaAppearance.palette.accentSoftFill;
  static Color get accentSoftBorder => DoayaAppearance.palette.accentSoftBorder;
  static Color get navActiveFill => DoayaAppearance.palette.navActiveFill;
  static Color get warningFill => DoayaAppearance.palette.warningFill;
  static Color get warningBorder => DoayaAppearance.palette.warningBorder;
  static Color get warningText => DoayaAppearance.palette.warningText;
  static Color get warningIcon => DoayaAppearance.palette.warningIcon;
  static Color get dangerFill => DoayaAppearance.palette.dangerFill;
  static Color get dangerBorder => DoayaAppearance.palette.dangerBorder;
  static Color get dangerText => DoayaAppearance.palette.dangerText;
  static Color get successDot => DoayaAppearance.palette.successDot;
  static Color get imageWell => DoayaAppearance.palette.imageWell;
  static Color get imageWellBorder => DoayaAppearance.palette.imageWellBorder;
  static Color get divider => DoayaAppearance.palette.divider;
  static Color get subtleFill => DoayaAppearance.palette.subtleFill;
  static Color get dotInactive => DoayaAppearance.palette.dotInactive;
  static Color get shadow => DoayaAppearance.palette.shadow;
  static Color get shadowStrong => DoayaAppearance.palette.shadowStrong;
  static Color get shadowSolid => DoayaAppearance.palette.shadowSolid;
  static Color get scrim => DoayaAppearance.palette.scrim;
  static const transparent = Color(0x00000000);
}
