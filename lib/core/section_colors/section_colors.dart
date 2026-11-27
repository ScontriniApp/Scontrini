import 'package:material_ui/material_ui.dart';

/// The colours the user picked for the plain sections (cards, history months,
/// pantry categories): everything that is neither printed on paper nor an
/// e-ink shelf label. Also the background of the whole app
/// ([appBackground]). `null` keeps the theme's colour.
@immutable
final class SectionColors {
  const new({this.background, this.text, this.appBackground, this.accent});

  static const none = SectionColors();

  final Color? background;
  final Color? text;

  /// Behind every screen (and the app bar); the theme turns light or dark
  /// to match it.
  final Color? appBackground;

  /// "Testo secondario": the accent of the whole app (headings, icons,
  /// buttons, "Aggiungi") in place of the amber. Not the pantry's, which
  /// comes from the pantry lab.
  final Color? accent;

  /// No section colour chosen (the app background doesn't count).
  bool get sectionsDefault => background == null && text == null;

  SectionColors _copy({
    Object? background = _keep,
    Object? text = _keep,
    Object? appBackground = _keep,
    Object? accent = _keep,
  }) => SectionColors(
    background: background == _keep ? this.background : background as Color?,
    text: text == _keep ? this.text : text as Color?,
    appBackground: appBackground == _keep
        ? this.appBackground
        : appBackground as Color?,
    accent: accent == _keep ? this.accent : accent as Color?,
  );

  static const _keep = Object();

  SectionColors withBackground(Color? value) => _copy(background: value);

  SectionColors withText(Color? value) => _copy(text: value);

  SectionColors withAppBackground(Color? value) => _copy(appBackground: value);

  SectionColors withAccent(Color? value) => _copy(accent: value);

  @override
  bool operator ==(Object other) =>
      other is SectionColors &&
      other.background == background &&
      other.text == text &&
      other.appBackground == appBackground &&
      other.accent == accent;

  @override
  int get hashCode => Object.hash(background, text, appBackground, accent);

  /// Background swatches offered in Settings: light papers, then darks.
  static const backgrounds = [
    Color(0xFFFFFFFF),
    Color(0xFFFFF8E1),
    Color(0xFFE8F5E9),
    Color(0xFFE3F2FD),
    Color(0xFFF3E5F5),
    Color(0xFFFCE4EC),
    Color(0xFFECEFF1),
    Color(0xFF263238),
    Color(0xFF1A237E),
    Color(0xFF1B5E20),
    Color(0xFF000000),
  ];

  /// Text swatches: inks for light backgrounds, then for dark ones
  /// (phosphor green and amber suit the terminal font).
  static const texts = [
    Color(0xFF000000),
    Color(0xFF424242),
    Color(0xFF1B5E20),
    Color(0xFF0D47A1),
    Color(0xFFB71C1C),
    Color(0xFF4E342E),
    Color(0xFFFFFFFF),
    Color(0xFF39FF14),
    Color(0xFFFFB000),
  ];
}
