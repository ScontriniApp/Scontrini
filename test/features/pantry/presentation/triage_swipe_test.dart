import 'package:cupertino_ui/cupertino_ui.dart'
    show GlobalCupertinoLocalizations;
import 'package:flutter_localizations/flutter_localizations.dart'
    show GlobalWidgetsLocalizations;
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:scontrini/features/pantry/domain/triage_grouping.dart';
import 'package:scontrini/features/pantry/presentation/triage_screen.dart';
import 'package:scontrini/features/pantry/presentation/triage_swipe.dart';
import 'package:scontrini/l10n/app_localizations.dart';

const _cards = [
  TriageCard(
    name: 'LATTE',
    unit: 'pz',
    quantity: 1,
    priceCents: 129,
    receiptItemIds: [1],
  ),
  TriageCard(
    name: 'PANE',
    unit: 'pz',
    quantity: 1,
    priceCents: 110,
    receiptItemIds: [2],
  ),
];

Widget _app(Widget home) => MaterialApp(
  locale: const Locale('it'),
  localizationsDelegates: const [
    AppLocalizations.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ],
  supportedLocales: AppLocalizations.supportedLocales,
  home: home,
);

void main() {
  late List<(String, TriageDecision)> decided;
  late List<(String, TriageDecision)> undone;

  Future<void> open(WidgetTester tester) async {
    decided = [];
    undone = [];
    await tester.pumpWidget(
      _app(
        TriageScreen(
          cards: Future.value(_cards),
          onDecision: (card, d) async => decided.add((card.name, d)),
          onUndo: (card, d) async => undone.add((card.name, d)),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('swiping right keeps, left skips, then a summary', (
    tester,
  ) async {
    await open(tester);
    expect(find.text('1 di 2'), findsOneWidget);

    await tester.drag(find.text('LATTE'), const Offset(400, 0));
    await tester.pumpAndSettle();
    expect(decided, [('LATTE', TriageDecision.keep)]);
    expect(find.text('2 di 2'), findsOneWidget);

    await tester.drag(find.text('PANE'), const Offset(-400, 0));
    await tester.pumpAndSettle();
    expect(decided.last, ('PANE', TriageDecision.skip));
    expect(find.text('1 in dispensa, 1 saltati.'), findsOneWidget);
  });

  testWidgets('a short drag puts the card back', (tester) async {
    await open(tester);
    await tester.drag(find.text('LATTE'), const Offset(40, 0));
    await tester.pumpAndSettle();
    expect(decided, isEmpty);
    expect(find.text('1 di 2'), findsOneWidget);
  });

  testWidgets('the buttons decide and the last decision can be undone', (
    tester,
  ) async {
    await open(tester);
    await tester.tap(find.byTooltip('In dispensa'));
    await tester.pumpAndSettle();
    expect(decided, [('LATTE', TriageDecision.keep)]);

    await tester.tap(find.text('Annulla'));
    await tester.pumpAndSettle();
    expect(undone, [('LATTE', TriageDecision.keep)]);
    expect(find.text('1 di 2'), findsOneWidget);
    expect(find.text('LATTE'), findsOneWidget);
  });
}
