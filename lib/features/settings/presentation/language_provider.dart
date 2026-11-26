import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scontrini/features/settings/data/language_store.dart';
import 'package:scontrini/features/settings/domain/app_language.dart';

/// Where the language choice is saved. In memory unless overridden (`main`
/// passes the device's shared preferences).
final languageStoreProvider = Provider<LanguageStore>(
  (ref) => MemoryLanguageStore(),
);

/// The language the app's text is shown in.
final appLanguageProvider = NotifierProvider<AppLanguageNotifier, AppLanguage>(
  AppLanguageNotifier.new,
);

class AppLanguageNotifier extends Notifier<AppLanguage> {
  @override
  AppLanguage build() =>
      AppLanguage.fromCode(ref.watch(languageStoreProvider).read()) ??
      AppLanguage.fallback;

  /// Switches the app to [language] and saves the choice.
  Future<void> select(AppLanguage language) async {
    if (language == state) return;
    state = language;
    await ref.read(languageStoreProvider).write(language.code);
  }
}
