import 'package:cupertino_ui/cupertino_ui.dart'
    show GlobalCupertinoLocalizations;
import 'package:drift/native.dart';
import 'package:flutter_localizations/flutter_localizations.dart'
    show GlobalWidgetsLocalizations;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:scontrini/core/database/app_database.dart';
import 'package:scontrini/core/database/database_provider.dart';
import 'package:scontrini/core/utils/clock.dart';
import 'package:scontrini/core/utils/money.dart';
import 'package:scontrini/features/analytics/data/demo_history_seed.dart';
import 'package:scontrini/features/analytics/presentation/analytics_screen.dart';
import 'package:scontrini/l10n/app_localizations.dart';

void main() {
  // A Monday.
  final today = DateTime(2026, 11, 23, 12);

  /// The visible tab's list (the tab pager and the hidden tab scroll too).
  final list = find
      .byWidgetPredicate(
        (w) => w is Scrollable && w.axisDirection == AxisDirection.down,
      )
      .hitTestable()
      .first;

  /// Lets Drift's stream deliver after a period change.
  Future<void> settle(WidgetTester tester) async {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 300)),
    );
    await tester.pumpAndSettle();
  }

  Future<void> pumpAnalytics(WidgetTester tester, {bool seed = false}) async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(() async {
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(seconds: 1));
      await db.close();
    });
    if (seed) {
      await tester.runAsync(() => seedDemoHistory(db, today: today));
    }
    // A narrow phone (360 × 960 dp), so overflows in the period bar show.
    tester.view.physicalSize = const Size(900, 2400);
    tester.view.devicePixelRatio = 2.5;
    addTearDown(tester.view.reset);

    final router = GoRouter(
      routes: [
        GoRoute(path: '/', builder: (_, _) => const AnalyticsScreen()),
        GoRoute(
          path: '/products/:id',
          builder: (_, state) => Text('product ${state.pathParameters['id']}'),
        ),
      ],
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          clockProvider.overrideWithValue(() => today),
        ],
        child: MaterialApp.router(
          routerConfig: router,
          locale: const Locale('it'),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
        ),
      ),
    );
    await settle(tester);
  }

  testWidgets('with no receipts both tabs say so', (tester) async {
    await pumpAnalytics(tester);

    expect(find.text('novembre 2026'), findsOneWidget);
    expect(find.text('Nessuno scontrino in questo periodo'), findsOneWidget);
    await tester.tap(find.text('Prodotti'));
    await tester.pumpAndSettle();
    expect(find.text('Nessuno scontrino in questo periodo'), findsOneWidget);
  });

  testWidgets('Spesa shows the month against the same days of October', (
    tester,
  ) async {
    await pumpAnalytics(tester, seed: true);

    expect(find.text('Speso'), findsOneWidget);
    expect(find.text(Money.format(10518)), findsOneWidget);
    expect(find.text('5 scontrini'), findsOneWidget);
    expect(find.textContaining('rispetto a 1 ott – 23 ott 2026'), findsOne);
    expect(find.text('Andamento'), findsOneWidget);
    expect(find.text('Carne e pesce'), findsOneWidget);

    await tester.scrollUntilVisible(find.text('Negozi'), 300, scrollable: list);
    expect(find.text('Supermercato Aurora'), findsWidgets);
    await tester.scrollUntilVisible(
      find.text('Risparmiato con gli sconti'),
      300,
      scrollable: list,
    );
    expect(find.text('Risparmiato con gli sconti'), findsOneWidget);
  });

  testWidgets('the period bar switches kind and steps back and forth', (
    tester,
  ) async {
    await pumpAnalytics(tester, seed: true);

    // The current month has no next period.
    final next = find.widgetWithIcon(IconButton, Icons.chevron_right);
    expect(tester.widget<IconButton>(next).onPressed, isNull);

    await tester.tap(find.byTooltip('Periodo precedente'));
    await settle(tester);
    expect(find.text('ottobre 2026'), findsOneWidget);
    // A finished month is compared with the whole month before.
    expect(find.textContaining('rispetto a settembre 2026'), findsOneWidget);

    await tester.tap(next);
    await settle(tester);
    expect(find.text('novembre 2026'), findsOneWidget);

    await tester.tap(find.text('Settimana'));
    await settle(tester);
    expect(find.text('23 nov – 29 nov 2026'), findsOneWidget);

    await tester.tap(find.text('Anno'));
    await settle(tester);
    expect(find.text('2026'), findsOneWidget);
  });

  testWidgets('Prodotti lists the most bought and the price changes; a tap '
      'opens the product', (tester) async {
    await pumpAnalytics(tester, seed: true);
    await tester.tap(find.text('Prodotti'));
    await tester.pumpAndSettle();

    expect(find.text('Più acquistati'), findsOneWidget);
    expect(find.text('Latte intero 1 l'), findsWidgets);

    await tester.scrollUntilVisible(
      find.text('In calo'),
      300,
      scrollable: list,
    );
    expect(find.text('In aumento'), findsOneWidget);
    expect(find.text('Caffè moka 250 g'), findsWidgets);
    // Milk up, coffee down; yogurt is only on offer, so it is listed
    // once (most bought), not as a drop.
    expect(find.text('+12%'), findsOneWidget);
    expect(find.text('−15%'), findsOneWidget);
    expect(find.text('Yogurt bianco x2'), findsOneWidget);

    final coffee = find.text('Caffè moka 250 g').last;
    await tester.ensureVisible(coffee);
    await tester.pumpAndSettle();
    await tester.tap(coffee);
    await tester.pumpAndSettle();
    expect(find.textContaining('product '), findsOneWidget);
  });
}
