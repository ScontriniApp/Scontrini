import 'dart:ui';

import 'package:scontrini/core/section_colors/section_colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Where the section colours are kept between launches.
abstract interface class SectionColorsStore {
  SectionColors read();

  Future<void> write(SectionColors colors);
}

/// In memory only: the default until `main` overrides it, so tests start
/// with the theme's colours and never touch the device.
class MemorySectionColorsStore implements SectionColorsStore {
  new([this._colors = SectionColors.none]);

  SectionColors _colors;

  @override
  SectionColors read() => _colors;

  @override
  Future<void> write(SectionColors colors) async => _colors = colors;
}

/// The device's shared preferences: four ARGB integers, absent for the
/// theme's colour.
class PreferencesSectionColorsStore implements SectionColorsStore {
  new(this._preferences);

  static const _background = 'section_background';
  static const _text = 'section_text';
  static const _app = 'app_background';
  static const _accent = 'accent_color';

  final SharedPreferencesWithCache _preferences;

  /// Loads the stored values, so [read] can answer synchronously at startup.
  static Future<PreferencesSectionColorsStore> open() async =>
      PreferencesSectionColorsStore(
        await SharedPreferencesWithCache.create(
          cacheOptions: const SharedPreferencesWithCacheOptions(
            allowList: {_background, _text, _app, _accent},
          ),
        ),
      );

  @override
  SectionColors read() => SectionColors(
    background: _color(_background),
    text: _color(_text),
    appBackground: _color(_app),
    accent: _color(_accent),
  );

  Color? _color(String key) => switch (_preferences.getInt(key)) {
    final int value => Color(value),
    null => null,
  };

  @override
  Future<void> write(SectionColors colors) async {
    await _save(_background, colors.background);
    await _save(_text, colors.text);
    await _save(_app, colors.appBackground);
    await _save(_accent, colors.accent);
  }

  Future<void> _save(String key, Color? color) => color == null
      ? _preferences.remove(key)
      : _preferences.setInt(key, color.toARGB32());
}
