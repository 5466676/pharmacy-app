import '../theme/doaya_appearance.dart';

/// Spacing scale, taken from the mockups.
abstract final class DoayaSpacing {
  static double get xxs => 2 * DoayaAppearance.density;
  static double get xs => 4 * DoayaAppearance.density;
  static double get s => 6 * DoayaAppearance.density;
  static double get sm => 8 * DoayaAppearance.density;
  static double get m => 10 * DoayaAppearance.density;
  static double get ml => 12 * DoayaAppearance.density;
  static double get l => 14 * DoayaAppearance.density;
  static double get xl => 16 * DoayaAppearance.density;
  static double get xxl => 18 * DoayaAppearance.density;
  static double get xxxl => 20 * DoayaAppearance.density;
  static double get huge => 24 * DoayaAppearance.density;
  static double get giant => 28 * DoayaAppearance.density;

  /// Horizontal padding of phone screens.
  static double get screenGutter => 18 * DoayaAppearance.density;

  /// Floating bottom nav / input bar distance from the screen sides.
  static double get floatingInset => 14 * DoayaAppearance.density;

  /// Floating bottom nav distance from the screen bottom.
  static double get floatingBottom => 18 * DoayaAppearance.density;
}

/// Corner radii.
abstract final class DoayaRadii {
  static const double pill = 999;
  static double get hairline => 3 * DoayaAppearance.roundness;
  static double get key => 8 * DoayaAppearance.roundness;
  static double get imageWell => 14 * DoayaAppearance.roundness;
  static double get tile => 18 * DoayaAppearance.roundness;
  static double get card => 20 * DoayaAppearance.roundness;
  static double get cardLarge => 22 * DoayaAppearance.roundness;
  static double get bottomNav => 26 * DoayaAppearance.roundness;
  static double get hero => 28 * DoayaAppearance.roundness;
  static double get sheet => 30 * DoayaAppearance.roundness;
  static double get splashCard => 34 * DoayaAppearance.roundness;
  static double get bubble => 22 * DoayaAppearance.roundness;
  static double get bubbleTail => 6 * DoayaAppearance.roundness;
}

/// Fixed component sizes.
abstract final class DoayaSizes {
  static const double iconTile = 54;
  static const double roundButton = 44;
  static const double buttonLarge = 56;
  static const double buttonMedium = 48;
  static const double buttonSmall = 38;
  static const double searchField = 48;
  static const double inputBar = 60;
  static const double bottomNav = 70;
  static const double bottomNavActive = 36;
  static const double avatar = 40;
  static const double statIcon = 32;
  static const double sidebarIcon = 30;
  static const double sidebarItem = 44;
  static const double sidebarWidth = 230;
  static const double railWidth = 84;
  static const double railButton = 48;
  static const double statusDot = 7;
  static const double badge = 16;
  static const double productImage = 82;
  static const double borderWidth = 1;
  static const double focusWidth = 2;

  static const double iconXs = 14;
  static const double iconSidebar = 16;
  static const double iconS = 18;
  static const double iconM = 20;
  static const double iconL = 22;
  static const double iconXl = 28;

  static const double logoSmall = 28;
  static const double logoMedium = 40;
  static const double logoLarge = 64;
  static const double logoHero = 110;

  static const double productIcon = 40;
  static const double swatchWidth = 80;
  static const double swatchHeight = 44;
  static const double desktopSearchWidth = 300;
  static const double dialogWidth = 460;
  static const double invoiceWidth = 380;
  static const double formWidth = 560;
  static const double pinKey = 64;
  static const double employeeTile = 140;
  static const double productThumb = 46;
  static const double qtyButton = 30;
  static const double listPaneWidth = 360;

  /// Label column of a key/value summary (a patient's case).
  static const double summaryLabelWidth = 110;
  static const double priceColumn = 110;
  static const double wideFormWidth = 780;

  /// Width breakpoint above which the gallery / apps use a desktop layout.
  static const double desktopBreakpoint = 900;

  /// Below this width the pharmacy app switches to its phone layout
  /// (bottom navigation, single-column screens).
  static const double phoneLayoutWidth = 700;

  /// Max content width for phone-style layouts on wide screens.
  static const double phoneMaxWidth = 480;
}

/// Blur sigmas (CSS `blur(n)` == sigma n).
abstract final class DoayaBlur {
  static double get glass => DoayaAppearance.look.blur;
  static double get glassStrong => DoayaAppearance.look.blur + 4;
  static const double leafNear = 4;
  static const double leafFar = 6;
  static const double photo = 12;
}

/// Opacity values used for state and decoration.
abstract final class DoayaOpacity {
  static const double disabled = 0.45;
  static const double blobLight = 0.85;
  static const double blobDark = 0.7;
  static const double leafNear = 0.5;
  static const double leafFar = 0.45;
}

/// Animation durations.
abstract final class DoayaDurations {
  static const fast = Duration(milliseconds: 120);
  static const medium = Duration(milliseconds: 220);
}
