import 'dart:async';
import 'dart:math' as math;

import 'package:cupertino_ui/cupertino_ui.dart'
    show GlobalCupertinoLocalizations;
import 'package:flutter_localizations/flutter_localizations.dart'
    show GlobalWidgetsLocalizations;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:scontrini/core/paper/paper_params.dart';
import 'package:scontrini/core/paper/paper_tilt.dart';
import 'package:scontrini/core/paper/receipt_paper.dart';
import 'package:scontrini/core/paper/tilt_filter.dart';
import 'package:scontrini/features/shader_lab/presentation/shader_lab_screen.dart';
import 'package:scontrini/l10n/app_localizations.dart';

/// A phone upright, leaning back by [pitch] radians, [ms] milliseconds in.
GravitySample held(double pitch, int ms) => (
  x: 0,
  y: math.cos(pitch) * 9.81,
  z: math.sin(pitch) * 9.81,
  time: DateTime(2026, 11, 26).add(Duration(milliseconds: ms)),
);

/// The lab with [gravity] as the accelerometer.
Future<ProviderContainer> pumpLab(
  WidgetTester tester,
  Stream<GravitySample> gravity, {
  bool reduceMotion = false,
}) async {
  tester.view.physicalSize = const Size(1080, 2400);
  tester.view.devicePixelRatio = 2.75;
  addTearDown(tester.view.reset);
  if (reduceMotion) {
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
  }

  final container = ProviderContainer(
    overrides: [gravityProvider.overrideWithValue(gravity)],
  );
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
  return container;
}

Offset paperTilt(WidgetTester tester) =>
    tester.widget<ReceiptPaper>(find.byType(ReceiptPaper)).tilt;

void main() {
  testWidgets('the lab loads the shader and paints the sample receipt', (
    tester,
  ) async {
    final container = await pumpLab(tester, const Stream.empty());

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

  testWidgets('tilting the phone swings the light; off stops listening', (
    tester,
  ) async {
    final gravity = StreamController<GravitySample>.broadcast();
    addTearDown(gravity.close);
    await pumpLab(tester, gravity.stream);
    expect(gravity.hasListener, isTrue);
    expect(paperTilt(tester), Offset.zero);

    for (var ms = 0; ms <= 1000; ms += 20) {
      gravity.add(held(0.6, ms));
    }
    for (var ms = 1020; ms <= 1400; ms += 20) {
      gravity.add(held(1, ms));
    }
    await tester.pump();
    expect(paperTilt(tester).dy, greaterThan(0.2));
    expect(find.textContaining(' 0.'), findsOneWidget);

    final toggle = find.text("Luce che segue l'inclinazione del telefono");
    await tester.ensureVisible(toggle);
    await tester.pump();
    await tester.tap(toggle);
    await tester.pump();
    expect(gravity.hasListener, isFalse);
    expect(paperTilt(tester), Offset.zero);
    expect(tester.takeException(), isNull);
  });

  testWidgets('without a sensor the switch says so and is off', (tester) async {
    await pumpLab(tester, Stream.error(StateError('no sensor')));
    await tester.pump();
    expect(
      find.text('Nessun sensore di movimento su questo dispositivo'),
      findsOneWidget,
    );
    final tile = tester.widget<SwitchListTile>(
      find.widgetWithText(
        SwitchListTile,
        "Luce che segue l'inclinazione del telefono",
      ),
    );
    expect(tile.value, isFalse);
    expect(tile.onChanged, isNull);
  });

  testWidgets('with reduce motion on, the sensor is never read', (
    tester,
  ) async {
    final gravity = StreamController<GravitySample>.broadcast();
    addTearDown(gravity.close);
    await pumpLab(tester, gravity.stream, reduceMotion: true);
    expect(gravity.hasListener, isFalse);
  });

  test('params copy and print as Dart', () {
    const params = PaperParams();
    expect(params.copyWith(depth: 1).depth, 1);
    expect(params.copyWith(), params);
    expect(params.toDart(), startsWith('PaperParams(seed: 1.00'));
    expect(params.toDart(), endsWith('tiltGain: 1.00, sheen: 0.30)'));
    expect(params.copyWith(sheen: 0.5), isNot(params));
  });
}
