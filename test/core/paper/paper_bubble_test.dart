import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:scontrini/core/paper/paper_bubble.dart';
import 'package:scontrini/core/paper/paper_params.dart';

void main() {
  setUp(() => PaperBubble.waitForPaper = true);
  tearDown(() => PaperBubble.waitForPaper = false);

  Future<ProviderContainer> pumpBubble(
    WidgetTester tester, {
    required VoidCallback onReady,
  }) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          home: Center(
            child: SizedBox(
              width: 300,
              child: PaperBubble(
                params: const PaperParams(),
                hideUntilReady: true,
                onReady: onReady,
                child: const SizedBox(height: 200, child: Text('PRINT')),
              ),
            ),
          ),
        ),
      ),
    );
    return container;
  }

  bool shown(WidgetTester tester) =>
      tester.widget<Visibility>(find.byType(Visibility).first).visible;

  testWidgets('hidden until the paper is baked, then ready once', (
    tester,
  ) async {
    var ready = 0;
    final container = await pumpBubble(tester, onReady: () => ready++);
    // Laid out (its size is known) but not shown: no unprinted flash.
    expect(tester.getSize(find.byType(PaperBubble)), const Size(300, 200));
    expect(shown(tester), isFalse);
    expect(ready, 0);

    await tester.runAsync(() => container.read(paperProgramProvider.future));
    // Size reported, creases built and decoded, sheet baked.
    for (var i = 0; i < 10 && !shown(tester); i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 20)),
      );
      await tester.pump();
    }
    expect(shown(tester), isTrue);
    expect(ready, 1);

    // Later rebuilds don't report again.
    await tester.pumpWidget(const SizedBox());
    expect(ready, 1);
  });

  testWidgets('shown anyway after the time limit', (tester) async {
    var ready = 0;
    await pumpBubble(tester, onReady: () => ready++);
    expect(shown(tester), isFalse);
    await tester.pump(PaperBubble.readyTimeout);
    await tester.pump();
    expect(shown(tester), isTrue);
    expect(ready, 1);
    await tester.pumpWidget(const SizedBox());
  });
}
