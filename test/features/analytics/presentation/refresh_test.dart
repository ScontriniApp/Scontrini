import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:scontrini/app/app.dart';
import 'package:scontrini/core/database/app_database.dart';
import 'package:scontrini/core/database/database_provider.dart';
import 'package:scontrini/core/utils/clock.dart';
import 'package:scontrini/features/analytics/data/demo_history_seed.dart';

void main() {
  // The app is left open late on 30 November; the test moves the clock past
  // midnight and refreshes.
  late DateTime now;

  Future<void> settle(WidgetTester tester) async {
    await tester.pump();
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 300)),
    );
    await tester.pumpAndSettle();
  }

  Future<void> pumpApp(WidgetTester tester) async {
    now = DateTime(2026, 11, 30, 23, 50);
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(() async {
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(seconds: 1));
      await db.close();
    });
    await tester.runAsync(() => seedDemoHistory(db, today: now));
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.5;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          clockProvider.overrideWithValue(() => now),
        ],
        child: const ScontriniApp(),
      ),
    );
    await settle(tester);
  }

  Finder tab(String label) => find.descendant(
    of: find.byType(NavigationBar),
    matching: find.text(label),
  );

  testWidgets('pulling the dashboard down moves it to the new day', (
    tester,
  ) async {
    await pumpApp(tester);
    expect(find.text('Speso a novembre'), findsOneWidget);

    now = DateTime(2026, 12, 1, 8);
    await tester.fling(find.byType(ListView).first, const Offset(0, 400), 1000);
    await settle(tester);

    expect(find.text('Speso a dicembre'), findsOneWidget);
  });

  testWidgets('tapping the open Home tab refreshes it', (tester) async {
    await pumpApp(tester);

    now = DateTime(2026, 12, 1, 8);
    await tester.tap(tab('Home'));
    await settle(tester);

    expect(find.text('Speso a dicembre'), findsOneWidget);
  });

  testWidgets('refreshing Analisi follows the current month to the new '
      'one, but keeps a month the user went back to', (tester) async {
    await pumpApp(tester);
    await tester.tap(tab('Analisi'));
    await settle(tester);
    expect(find.text('novembre 2026'), findsOneWidget);

    now = DateTime(2026, 12, 1, 8);
    await tester.tap(tab('Analisi'));
    await settle(tester);
    expect(find.text('dicembre 2026'), findsOneWidget);

    // Back to October, then another day passes: October stays.
    await tester.tap(find.byTooltip('Periodo precedente'));
    await settle(tester);
    await tester.tap(find.byTooltip('Periodo precedente'));
    await settle(tester);
    expect(find.text('ottobre 2026'), findsOneWidget);

    now = DateTime(2026, 12, 2, 8);
    await tester.fling(find.byType(ListView).first, const Offset(0, 400), 1000);
    await settle(tester);
    expect(find.text('ottobre 2026'), findsOneWidget);
  });
}
