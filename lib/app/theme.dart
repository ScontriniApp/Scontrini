import 'package:material_ui/material_ui.dart';

abstract final class AppTheme {
  /// The app's accent (icons, headings, buttons): an amber, also the seed
  /// of every theme's palette.
  static const accent = Color(0xFFC58003);

  /// Text and icons on [accent] (buttons).
  static const onAccent = Color(0xFFFFF5DC);

  static const Color _seed = accent;

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

  /// Font and accent on every theme: the palette's primary is [accent]
  /// exactly (the seed alone shifts it), with [onAccent] on it; the
  /// "Aggiungi" button is filled with it too.
  static ThemeData _withFont(ThemeData theme) => theme.copyWith(
    colorScheme: theme.colorScheme.copyWith(
      primary: accent,
      onPrimary: onAccent,
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: accent,
      foregroundColor: onAccent,
    ),
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
