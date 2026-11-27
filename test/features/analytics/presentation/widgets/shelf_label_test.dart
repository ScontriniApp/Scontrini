import 'dart:math' as math;

import 'package:flutter/rendering.dart';
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

  testWidgets('a drag that starts on the plate tilts it, not the list', (
    tester,
  ) async {
    final container = ProviderContainer(
      overrides: [
        plasticSettingsStoreProvider.overrideWithValue(
          MemorySettingsStore(const PlasticParams()),
        ),
      ],
    );
    addTearDown(container.dispose);
    final scroll = ScrollController();
    addTearDown(scroll.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          home: Scaffold(
            body: ListView(
              controller: scroll,
              padding: const EdgeInsets.all(24),
              children: const [
                ShelfLabel(
                  title: 'Speso',
                  cents: 1234,
                  leading: '3 scontrini',
                  footer: 'Di solito 10,00 €',
                ),
                SizedBox(height: 2000),
              ],
            ),
          ),
        ),
      ),
    );

    // Dragged up from the label's right side: the list stays, the plate
    // follows the finger.
    final plate = tester.getRect(find.byType(PlasticPlate));
    final start = plate.centerRight - const Offset(10, 0);
    final gesture = await tester.startGesture(start);
    await gesture.moveBy(const Offset(0, -10));
    await gesture.moveBy(const Offset(0, -20));
    await frames(tester);
    expect(scroll.offset, 0);
    expect(tiltY(tester), lessThan(0));
    await gesture.up();
    await tester.pumpAndSettle();

    // The same drag below the label scrolls.
    await tester.dragFrom(
      Offset(start.dx, plate.bottom + 100),
      const Offset(0, -200),
    );
    await tester.pumpAndSettle();
    expect(scroll.offset, greaterThan(0));
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('the plate is drawn above the cards around it', (tester) async {
    final container = ProviderContainer(
      overrides: [
        plasticSettingsStoreProvider.overrideWithValue(
          MemorySettingsStore(const PlasticParams()),
        ),
      ],
    );
    addTearDown(container.dispose);
    final scroll = ScrollController();
    addTearDown(scroll.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          home: Scaffold(
            appBar: AppBar(title: const Text('Analisi')),
            body: ListView(
              key: const Key('list'),
              controller: scroll,
              padding: const EdgeInsets.all(24),
              children: const [
                ShelfLabel(
                  title: 'Speso',
                  cents: 1234,
                  leading: '3 scontrini',
                  footer: 'Di solito 10,00 €',
                ),
                Card(key: Key('next'), child: SizedBox(height: 300)),
                SizedBox(height: 2000),
              ],
            ),
          ),
        ),
      ),
    );

    // One visible copy of the label (the one in place is invisible), and it
    // is painted on the overlay, not inside the list with the card.
    expect(find.text('SPESO'), findsOneWidget);
    bool inList(Finder finder) {
      final list = tester.renderObject(find.byKey(const Key('list')));
      for (RenderObject? n = tester.renderObject(finder); n != null;) {
        if (n == list) return true;
        n = n.parent;
      }
      return false;
    }

    expect(inList(find.byKey(const Key('next'))), isTrue);
    expect(inList(find.text('SPESO')), isFalse);

    // Printed where the label is laid out.
    Offset textInPlate() =>
        tester.getTopLeft(find.text('SPESO')) -
        tester.getTopLeft(find.byType(PlasticPlate));
    final before = textInPlate();
    expect(
      tester
          .getRect(find.byType(PlasticPlate))
          .contains(tester.getCenter(find.text('SPESO'))),
      isTrue,
    );

    // Clipped to the list: it never paints over the app bar.
    final clip = tester.renderObject<RenderClipRect>(
      find
          .descendant(
            of: find.byType(PlasticPlate),
            matching: find.byType(ClipRect),
          )
          .first,
    );
    expect(
      clip.clipper!.getClip(Size.zero),
      tester.getRect(find.byKey(const Key('list'))),
    );

    // Scrolled, the plate follows the list.
    scroll.jumpTo(40);
    await tester.pump();
    expect(tester.getTopLeft(find.byType(PlasticPlate)).dy, lessThan(80));
    expect(textInPlate(), before);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('a flat label has no plate', (tester) async {
    await pumpLabel(tester, plastic: false);
    expect(find.byType(PlasticPlate), findsNothing);
    expect(find.text('SPESO'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });
}
