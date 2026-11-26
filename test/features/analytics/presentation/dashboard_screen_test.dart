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
import 'package:scontrini/core/utils/clock.dart';
import 'package:scontrini/core/utils/money.dart';
import 'package:scontrini/features/analytics/data/demo_history_seed.dart';
import 'package:scontrini/features/analytics/presentation/dashboard_screen.dart';
import 'package:scontrini/l10n/app_localizations.dart';

void main() {
  final today = DateTime(2026, 11, 23, 12);

  Future<AppDatabase> pumpDashboard(
    WidgetTester tester, {
    bool seed = false,
  }) async {
    final db = AppDatabase(NativeDatabase.memory());
    // Unmount first so the history stream is cancelled, and let Drift's
    // pending timers run before closing.
    addTearDown(() async {
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(seconds: 1));
      await db.close();
    });
    if (seed) {
      await tester.runAsync(() => seedDemoHistory(db, today: today));
    }
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          clockProvider.overrideWithValue(() => today),
        ],
        child: const MaterialApp(
          locale: Locale('it'),
          localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: DashboardScreen(),
        ),
      ),
    );
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 300)),
    );
    await tester.pump();
    return db;
  }

  testWidgets('with no receipts it shows the empty state', (tester) async {
    await pumpDashboard(tester);
    expect(find.textContaining('Nessuno scontrino ancora'), findsOneWidget);
    expect(find.text('Categorie del mese'), findsNothing);
  });

  testWidgets('on the demo history it shows the month, categories and '
      'the suggestions space', (tester) async {
    await pumpDashboard(tester, seed: true);

    expect(find.text('SPESO A NOVEMBRE'), findsOneWidget);
    // The shelf label splits the price into euros and cents; screen
    // readers get it whole.
    expect(find.text('105'), findsOneWidget);
    expect(
      find.byWidgetPredicate(
        (w) => w is Semantics && w.properties.label == Money.format(10518),
      ),
      findsOneWidget,
    );
    expect(find.text('5 scontrini'), findsOneWidget);
    expect(find.textContaining('a questo punto del mese'), findsOneWidget);

    expect(find.text('Categorie del mese'), findsOneWidget);
    expect(find.text('Carne e pesce'), findsOneWidget);
    // Every category with spending is its own slice, smaller ones included.
    expect(find.text('Bevande'), findsOneWidget);
    expect(find.text('Latticini e uova'), findsOneWidget);
    expect(find.text('Altre categorie'), findsNothing);

    await tester.scrollUntilVisible(find.text('Consigli'), 200);
    expect(find.text('Consigli'), findsOneWidget);
  });

  testWidgets('tapping a category lists its items', (tester) async {
    await pumpDashboard(tester, seed: true);

    await tester.tap(find.text('Carne e pesce'));
    await tester.pumpAndSettle();

    expect(find.text('Petto di pollo'), findsWidgets);
    expect(find.textContaining('21 nov 2026'), findsWidgets);
    expect(find.textContaining('Supermercato Aurora'), findsWidgets);
    expect(find.text(Money.format(3701)), findsWidgets);
  });

  testWidgets('the next-shopping list shows what ran out', (tester) async {
    await pumpDashboard(tester, seed: true);

    await tester.scrollUntilVisible(find.text('Prossima spesa'), 200);
    expect(find.text('Prossima spesa'), findsOneWidget);
    // In the demo, yogurt and water go within two days of the last trip.
    expect(find.text('Yogurt bianco x2'), findsOneWidget);
    expect(find.text('Acqua naturale 6×1,5 l'), findsOneWidget);
    expect(
      find.text('Finito in dispensa · di solito ogni 7 giorni'),
      findsNWidgets(2),
    );
  });

  testWidgets('the suggestions show the drinks spike and products often '
      'thrown away, ranked', (tester) async {
    await pumpDashboard(tester, seed: true);

    await tester.scrollUntilVisible(find.text('Consigli'), 200);
    await tester.scrollUntilVisible(find.textContaining('Bevande: +'), 200);
    expect(find.textContaining('rispetto al solito'), findsOneWidget);
    expect(find.text('Butti spesso: Macinato di manzo 500 g'), findsOneWidget);
    // Three shown, the rest behind "Mostra tutti".
    expect(find.textContaining('Butti spesso:'), findsNWidgets(2));
    await tester.scrollUntilVisible(find.text('Mostra tutti (5)'), 200);
    await tester.ensureVisible(find.text('Mostra tutti (5)'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Mostra tutti (5)'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Butti spesso: Latte intero 1 l'),
      200,
    );
    expect(find.text('Butti spesso: Latte intero 1 l'), findsOneWidget);
    expect(find.text('Mostra meno'), findsOneWidget);
  });
}
