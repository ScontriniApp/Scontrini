import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:scontrini/core/plastic/plastic_params.dart';
import 'package:scontrini/core/plastic/plastic_plate.dart';
import 'package:scontrini/core/plastic/plastic_settings.dart';
import 'package:scontrini/core/utils/settings_store.dart';
import 'package:scontrini/features/analytics/presentation/widgets/shelf_label.dart';

void main() {
  Future<ProviderContainer> pumpLabel(
    WidgetTester tester, {
    bool plastic = true,
    PlasticParams saved = const PlasticParams(),
  }) async {
    final container = ProviderContainer(
      overrides: [
        plasticSettingsStoreProvider.overrideWithValue(
          MemorySettingsStore(saved),
        ),
      ],
    );
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          home: Scaffold(
            body: Padding(
              padding: const EdgeInsets.all(24),
              child: ShelfLabel(
                title: 'Speso',
                cents: 1234,
                leading: '3 scontrini',
                footer: 'Di solito 10,00 €',
                plastic: plastic,
              ),
            ),
          ),
        ),
      ),
    );
    return container;
  }

  /// A second of 60 fps frames (one long frame moves the spring 50 ms).
  Future<void> frames(WidgetTester tester) async {
    for (var i = 0; i < 60; i++) {
      await tester.pump(const Duration(milliseconds: 16));
    }
  }

  /// Rotation of the plate's face about the vertical axis, from its matrix.
  double tiltY(WidgetTester tester) {
    final face = tester
        .widgetList<Transform>(
          find.descendant(
            of: find.byType(PlasticPlate),
            matching: find.byType(Transform),
          ),
        )
        .last
        .transform;
    // With tiltX = 0, column 0 of Rx · Ry · scale is lift·(cos, 0, −sin).
    return math.atan2(-face.entry(2, 0), face.entry(0, 0));
  }

  testWidgets('the app-wide label is a plastic plate with the saved look', (
    tester,
  ) async {
    const saved = PlasticParams(tilt: 0.3, damping: 30);
    final container = await pumpLabel(tester, saved: saved);
    expect(find.byType(PlasticPlate), findsOneWidget);
    expect(container.read(plasticSettingsProvider), saved);

    // Pressed at the right edge it tilts by the saved amount.
    final plate = tester.getRect(find.byType(PlasticPlate));
    final gesture = await tester.startGesture(
      plate.centerRight - const Offset(2, 0),
    );
    await frames(tester);
    expect(tiltY(tester), closeTo(-0.3, 0.01));

    // A change made in the lab reaches the label at the next touch.
    container
        .read(plasticSettingsProvider.notifier)
        .set(saved.copyWith(tilt: 0.1));
    await tester.pump();
    await gesture.moveBy(const Offset(-1, 0));
    await frames(tester);
    expect(tiltY(tester), closeTo(-0.1, 0.01));

    // Sliding off the label lets it go.
    await gesture.moveTo(plate.centerRight + const Offset(80, 0));
    await tester.pumpAndSettle();
    expect(tiltY(tester), closeTo(0, 1e-3));
    await gesture.up();
    // Unmount before the container goes.
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('a flat label has no plate', (tester) async {
    await pumpLabel(tester, plastic: false);
    expect(find.byType(PlasticPlate), findsNothing);
    expect(find.text('SPESO'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });
}
