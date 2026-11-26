/// The languages the app's own text comes in. Names from receipts
/// (products, stores) stay as printed whatever the choice.
enum AppLanguage {
  italian('it', 'Italiano'),
  english('en', 'English');

  new(this.code, this.nativeName);

  /// Language code: the ARB file (`app_<code>.arb`) and the number formats.
  final String code;

  /// The language's name in that language, so it reads the same in either UI.
  final String nativeName;

  /// The app's language before the user picks one.
  static const AppLanguage fallback = AppLanguage.italian;

  /// The language with [code], or `null` for an unknown or missing one.
  static AppLanguage? fromCode(String? code) {
    for (final l in values) {
      if (l.code == code) return l;
    }
    return null;
  }
}
