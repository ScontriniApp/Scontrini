import 'package:shared_preferences/shared_preferences.dart';

/// Where the chosen language is kept between launches.
abstract interface class LanguageStore {
  /// The saved language code, or `null` before the user picks one.
  String? read();

  Future<void> write(String code);
}

/// Keeps the choice in memory only: the default until `main` overrides it,
/// so tests start in the fallback language and never touch the device.
class MemoryLanguageStore implements LanguageStore {
  new([this._code]);

  String? _code;

  @override
  String? read() => _code;

  @override
  Future<void> write(String code) async => _code = code;
}

/// The device's shared preferences (app-private storage; not encrypted,
/// and it holds nothing but the language code).
class PreferencesLanguageStore implements LanguageStore {
  new(this._preferences);

  static const _key = 'app_language';

  final SharedPreferencesWithCache _preferences;

  /// Loads the stored value, so [read] can answer synchronously at startup.
  static Future<PreferencesLanguageStore> open() async =>
      PreferencesLanguageStore(
        await SharedPreferencesWithCache.create(
          cacheOptions: const SharedPreferencesWithCacheOptions(
            allowList: {_key},
          ),
        ),
      );

  @override
  String? read() => _preferences.getString(_key);

  @override
  Future<void> write(String code) => _preferences.setString(_key, code);
}
