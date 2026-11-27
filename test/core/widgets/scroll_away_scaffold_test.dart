import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:scontrini/core/widgets/scroll_away_scaffold.dart';

void main() {
  Future<void> pumpPage(WidgetTester tester) => tester.pumpWidget(
    MaterialApp(
      home: ScrollAwayScaffold(
        title: const Text('Titolo'),
        body: ListView(
          children: [
            for (var i = 0; i < 60; i++)
              SizedBox(height: 48, child: Text('Riga $i')),
          ],
        ),
      ),
    ),
  );

  // The list starts where the bar ends (the bar isn't built once hidden).
  double barTop(WidgetTester tester) =>
      tester.getTopLeft(find.byType(ListView)).dy;

  testWidgets('the bar slides away at the scroll pace and comes back', (
    tester,
  ) async {
    await pumpPage(tester);
    final start = barTop(tester);
    final list = find.byType(ListView);

    // Down 20 px: the bar has gone up 20 px, no snapping.
    await tester.drag(list, const Offset(0, -20));
    await tester.pumpAndSettle();
    expect(barTop(tester), moreOrLessEquals(start - 20));

    // Far down: the bar is gone.
    await tester.drag(list, const Offset(0, -600));
    await tester.pumpAndSettle();
    expect(find.text('Titolo'), findsNothing);
    expect(barTop(tester), moreOrLessEquals(start - kToolbarHeight));

    // Up 30 px in the middle of the list: 30 px of the bar are back.
    final hidden = barTop(tester);
    await tester.drag(list, const Offset(0, 30));
    await tester.pumpAndSettle();
    expect(barTop(tester), moreOrLessEquals(hidden + 30));
    expect(find.text('Riga 0'), findsNothing);

    // Back over the scrolled list, it has the page's background, untinted.
    final material = tester.widget<Material>(
      find
          .descendant(of: find.byType(AppBar), matching: find.byType(Material))
          .first,
    );
    expect(
      material.color,
      Theme.of(tester.element(list)).scaffoldBackgroundColor,
    );
    expect(material.elevation, 0);

    // Further up: the whole bar is back.
    await tester.drag(list, const Offset(0, 200));
    await tester.pumpAndSettle();
    expect(barTop(tester), moreOrLessEquals(start));
  });
}
