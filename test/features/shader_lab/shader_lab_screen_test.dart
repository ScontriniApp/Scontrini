import 'package:cupertino_ui/cupertino_ui.dart'
    show GlobalCupertinoLocalizations;
import 'package:flutter_localizations/flutter_localizations.dart'
    show GlobalWidgetsLocalizations;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:scontrini/core/paper/paper_params.dart';
import 'package:scontrini/core/paper/receipt_paper.dart';
import 'package:scontrini/features/shader_lab/presentation/shader_lab_screen.dart';
import 'package:scontrini/l10n/app_localizations.dart';

void main() {
  testWidgets('the lab loads the shader and paints the sample receipt', (
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

    // The shader asset compiles and loads.
    await tester.runAsync(
      () => container.read(receiptPaperProgramProvider.future),
    );
    await tester.pump();
    expect(container.read(receiptPaperProgramProvider).hasValue, isTrue);
    expect(find.text('MERCATO DEL CORSO'), findsOneWidget);
    expect(find.byType(CustomPaint), findsWidgets);

    // Knobs repaint without errors.
    await tester.tap(find.text('Nuove pieghe'));
    await tester.pump();
    await tester.dragUntilVisible(
      find.text('depth'),
      find.byType(ListView),
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
    expect(tester.takeException(), isNull);
  });

  test('params copy and print as Dart', () {
    const params = PaperParams();
    expect(params.copyWith(depth: 1).depth, 1);
    expect(params.copyWith(), params);
    expect(params.toDart(), startsWith('PaperParams(seed: 1.00'));
  });
}
