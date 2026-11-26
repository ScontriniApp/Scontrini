import 'package:cupertino_ui/cupertino_ui.dart'
    show GlobalCupertinoLocalizations;
import 'package:flutter_localizations/flutter_localizations.dart'
    show GlobalWidgetsLocalizations;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:scontrini/core/paper/paper_bubble.dart';
import 'package:scontrini/core/paper/paper_params.dart';
import 'package:scontrini/features/shader_lab/presentation/shader_lab_screen.dart';
import 'package:scontrini/l10n/app_localizations.dart';

void main() {
  testWidgets('the lab paints the receipt and the component gallery', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.75;
    addTearDown(tester.view.reset);

    final container = ProviderContainer();
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          locale: Locale('it'),
          localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: ShaderLabScreen(),
        ),
      ),
    );

    // The shader asset compiles and loads; the fold map decodes.
    await tester.runAsync(() => container.read(paperProgramProvider.future));
    await tester.pump();
    await tester.runAsync(() => Future<void>.delayed(Duration.zero));
    await tester.pump();
    expect(container.read(paperProgramProvider).hasValue, isTrue);
    expect(find.text('MERCATO DEL CORSO'), findsOneWidget);
    expect(find.byType(CustomPaint), findsWidgets);

    // The receipt scrolls inside its paper.
    await tester.drag(find.text('PANE COMUNE'), const Offset(0, -200));
    await tester.pump();
    expect(tester.takeException(), isNull);

    // Knobs and the light repaint without errors.
    await tester.tap(find.text('Nuove pieghe'));
    await tester.pump();
    await tester.dragUntilVisible(
      find.text('depth'),
      find.byType(ListView).last,
      const Offset(0, -100),
    );
    await tester.drag(
      find.descendant(
        of: find.ancestor(of: find.text('depth'), matching: find.byType(Row)),
        matching: find.byType(Slider),
      ),
      const Offset(60, 0),
    );
    await tester.pump();
    final before = container.read(paperLightProvider);
    container
        .read(paperLightProvider.notifier)
        .set(before.copyWith(azimuth: 0.5));
    await tester.pump();
    expect(tester.takeException(), isNull);

    // Components: chart, slider, icons, each on its own paper.
    await tester.tap(find.text('Componenti'));
    await tester.pump();
    await tester.runAsync(() => Future<void>.delayed(Duration.zero));
    await tester.pump();
    expect(find.text('SPESA DI NOVEMBRE'), findsOneWidget);
    expect(find.byType(PaperBubble), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('the paper bleeds past the bubble, centred, same layout', (
    tester,
  ) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          home: Center(
            child: SizedBox(
              width: 300,
              child: PaperBubble(
                params: PaperParams(depth: 2, cameraTilt: 0.8),
                child: SizedBox(height: 200),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.runAsync(() => container.read(paperProgramProvider.future));
    await tester.pump();
    // Size reported, then the fold map decodes.
    for (var i = 0; i < 3; i++) {
      await tester.runAsync(() => Future<void>.delayed(Duration.zero));
      await tester.pump();
    }

    final bubble = tester.getRect(find.byType(PaperBubble));
    expect(bubble.size, const Size(300, 200));
    final paper = tester.getRect(
      find.descendant(
        of: find.byType(PaperBubble),
        matching: find.byType(CustomPaint),
      ),
    );
    expect(paper.width, greaterThan(bubble.width));
    expect(paper.center.dx, closeTo(bubble.center.dx, 0.01));
    expect(paper.center.dy, closeTo(bubble.center.dy, 0.01));
    expect(tester.takeException(), isNull);
  });

  test('params copy and print as Dart', () {
    const params = PaperParams();
    expect(params.copyWith(depth: 2).depth, 2);
    expect(params.copyWith(), params);
    expect(params.toDart(), startsWith('PaperParams(seed: 1.00'));
    expect(params.toDart(), contains('ink: PaperInk.thermal'));
  });

  test('light from the top points up the screen and out of it', () {
    const light = PaperLight(azimuth: 1.5707963267948966, elevation: 0.5);
    final (x, y, z) = light.direction;
    expect(x, closeTo(0, 1e-9));
    expect(y, lessThan(0));
    expect(z, greaterThan(0));
  });
}
