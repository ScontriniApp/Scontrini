import 'package:cupertino_ui/cupertino_ui.dart'
    show GlobalCupertinoLocalizations;
import 'package:drift/native.dart';
import 'package:flutter_localizations/flutter_localizations.dart'
    show GlobalWidgetsLocalizations;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:scontrini/core/database/app_database.dart';
import 'package:scontrini/core/database/database_provider.dart';
import 'package:scontrini/features/settings/presentation/settings_screen.dart';
import 'package:scontrini/l10n/app_localizations.dart';

void main() {
  testWidgets('settings loads and removes the demo data', (tester) async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(db)],
        child: const MaterialApp(
          locale: Locale('it'),
          localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: SettingsScreen(),
        ),
      ),
    );

    Future<int> receipts() => tester
        .runAsync(() async => (await db.select(db.receipts).get()).length)
        .then((n) => n!);

    // Below the other settings: scroll to it first.
    await tester.scrollUntilVisible(find.text('Carica dati demo'), 200);
    await tester.ensureVisible(find.text('Carica dati demo'));
    await tester.pump();
    await tester.runAsync(() async {
      await tester.tap(find.text('Carica dati demo'));
      await Future<void>.delayed(const Duration(seconds: 1));
    });
    await tester.pump();
    expect(await receipts(), greaterThan(0));
    expect(find.textContaining('scontrini demo'), findsOneWidget);

    await tester.scrollUntilVisible(find.text('Rimuovi dati demo'), 200);
    await tester.ensureVisible(find.text('Rimuovi dati demo'));
    await tester.pump();
    await tester.runAsync(() async {
      await tester.tap(find.text('Rimuovi dati demo'));
      await Future<void>.delayed(const Duration(milliseconds: 500));
    });
    await tester.pump();
    expect(await receipts(), 0);
    expect(find.text('Dati demo rimossi'), findsOneWidget);

    // Settings watches the receipts (export entry): unmount before the
    // database closes, or the open drift stream keeps the test waiting.
    await tester.pumpWidget(const SizedBox());
    await tester.pump(Duration.zero);
  });
}
