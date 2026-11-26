import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:scontrini/app/app.dart';
import 'package:scontrini/core/database/app_database.dart';
import 'package:scontrini/core/database/database_provider.dart';
import 'package:scontrini/core/utils/money.dart';
import 'package:scontrini/features/settings/data/language_store.dart';
import 'package:scontrini/features/settings/presentation/language_provider.dart';

void main() {
  late AppDatabase db;

  setUp(() => db = AppDatabase(NativeDatabase.memory()));
  tearDown(() => Money.locale = 'it');

  Future<void> pumpApp(WidgetTester tester, LanguageStore store) async {
    // Unmount first so the dashboard's streams are cancelled, and let
    // Drift's pending timers run before closing.
    addTearDown(() async {
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(seconds: 1));
      await db.close();
    });
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          languageStoreProvider.overrideWithValue(store),
        ],
        child: const ScontriniApp(),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('Settings switches the app to English and saves the choice', (
    tester,
  ) async {
    final store = MemoryLanguageStore();
    await pumpApp(tester, store);

    expect(find.text('Storico'), findsOneWidget);
    await tester.tap(find.byTooltip('Impostazioni'));
    await tester.pumpAndSettle();
    expect(find.text('Lingua'), findsOneWidget);

    await tester.tap(find.text('English'));
    await tester.pumpAndSettle();

    expect(find.text('Language'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);
    expect(store.read(), 'en');
    expect(Money.locale, 'en');

    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    expect(find.text('History'), findsOneWidget);

    // And back.
    await tester.tap(find.byTooltip('Settings'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Italiano'));
    await tester.pumpAndSettle();
    expect(find.text('Lingua'), findsOneWidget);
    expect(store.read(), 'it');
    expect(Money.locale, 'it');
  });

  testWidgets('a saved choice is used from the first frame', (tester) async {
    await pumpApp(tester, MemoryLanguageStore('en'));

    expect(find.text('History'), findsOneWidget);
    expect(find.text('Storico'), findsNothing);
  });
}
