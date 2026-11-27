import 'package:material_ui/material_ui.dart';

abstract final class AppTheme {
  static const _seed = Color(0xFF2E7D5B);

  /// Pixel terminal font (VT323, bundled in assets/fonts/), used for all
  /// text.
  static const fontFamily = 'VT323';

  /// VT323 draws small for its point size: text is scaled up so it reads
  /// like the default sizes.
  static const _fontScale = 1.25;

  /// VT323's letters sit small in their line, so Material's line heights
  /// (1.2–1.5) look double-spaced: tighten them.
  static const _lineHeightScale = 0.8;

  /// Soft white behind every light screen.
  static const background = Color(0xFFFFFCF2);

  static final ThemeData light = _withFont(
    ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: _seed)
          .copyWith(surface: background),
      scaffoldBackgroundColor: background,
      fontFamily: fontFamily,
    ),
  );

  static final ThemeData dark = _withFont(
    ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: _seed,
        brightness: Brightness.dark,
      ),
      fontFamily: fontFamily,
    ),
  );

  /// The theme over a background the user chose (Settings): light or dark
  /// after the colour's brightness, so text, app bar and cards stay
  /// readable on it. Used for both the light and the dark system mode.
  static ThemeData onBackground(Color color) => _withFont(
    ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: _seed,
        brightness: ThemeData.estimateBrightnessForColor(color),
      ).copyWith(surface: color),
      scaffoldBackgroundColor: color,
      fontFamily: fontFamily,
    ),
  );

  static ThemeData _withFont(ThemeData theme) => theme.copyWith(
    textTheme: _scaled(theme.textTheme),
    primaryTextTheme: _scaled(theme.primaryTextTheme),
  );

  // The theme's text styles carry colours but no sizes (Material adds them
  // later), so start from the Material 3 sizes to scale them.
  static TextTheme _scaled(TextTheme styles) => Typography.englishLike2021
      .merge(styles)
      .apply(
        fontFamily: fontFamily,
        fontSizeFactor: _fontScale,
        heightFactor: _lineHeightScale,
      );
}
