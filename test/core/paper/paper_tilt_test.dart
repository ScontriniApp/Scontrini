import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:scontrini/core/paper/paper_bubble.dart';
import 'package:scontrini/core/paper/paper_params.dart';

void main() {
  group('paperOutline', () {
    test('a plain sheet is its rectangle', () {
      final path = paperOutline(const Size(300, 200), torn: 0, corner: 0);
      expect(path.getBounds(), const Rect.fromLTWH(0, 0, 300, 200));
    });

    test('torn ends have the shader teeth, top and bottom', () {
      // Teeth 6 wide: deepest (3) at x = 0, 6, ...; flush at x = 3, 9, ...
      final path = paperOutline(const Size(300, 200), torn: 6, corner: 0);
      expect(path.contains(const Offset(0.5, 1)), isFalse);
      expect(path.contains(const Offset(3, 1)), isTrue);
      expect(path.contains(const Offset(0.5, 199)), isFalse);
      expect(path.contains(const Offset(3, 199)), isTrue);
      expect(path.contains(const Offset(150, 100)), isTrue);
    });

    test('rounded corners', () {
      final path = paperOutline(const Size(300, 200), torn: 0, corner: 12);
      expect(path.contains(const Offset(1, 1)), isFalse);
      expect(path.contains(const Offset(12, 12)), isTrue);
    });

    test('only the visible rows of a long sheet', () {
      final path = paperOutline(
        const Size(300, 5000),
        torn: 6,
        corner: 0,
        top: 1000,
        bottom: 1800,
      );
      expect(path.getBounds(), const Rect.fromLTRB(0, 1000, 300, 1800));
    });
  });

  Future<void> pump(
    WidgetTester tester, {
    required PaperParams params,
    bool tilt = true,
    ScrollController? controller,
    VoidCallback? onTap,
  }) async {
    final content = SizedBox(
      height: 200,
      child: Center(
        child: TextButton(onPressed: onTap, child: const Text('TAP')),
      ),
    );
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: ListView(
              padding: const EdgeInsets.all(40),
              children: [
                PaperBubble(
                  params: params,
                  tilt: tilt,
                  controller: controller,
                  child: controller == null
                      ? content
                      : SizedBox(
                          height: 200,
                          child: SingleChildScrollView(
                            controller: controller,
                            child: content,
                          ),
                        ),
                ),
                const SizedBox(height: 2000),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pump();
  }

  Future<void> frames(WidgetTester tester) async {
    for (var i = 0; i < 60; i++) {
      await tester.pump(const Duration(milliseconds: 16));
    }
  }

  /// The sheet's tilt: the transform around its own layer.
  Finder tiltTransforms() => find.descendant(
    of: find.byType(PaperBubble),
    matching: find.byWidgetPredicate(
      (w) => w is Transform && w.child is RepaintBoundary,
    ),
  );

  /// Rotation of the sheet about the vertical axis, from its matrix.
  double tiltY(WidgetTester tester) {
    final sheet = tester.widgetList<Transform>(tiltTransforms()).last.transform;
    // With tiltX = 0, column 0 of Rx · Ry · scale is lift·(cos, 0, −sin).
    return math.atan2(-sheet.entry(2, 0), sheet.entry(0, 0));
  }

  bool hasShadow(WidgetTester tester) => tester
      .widgetList<CustomPaint>(find.byType(CustomPaint))
      .any((p) => p.painter.runtimeType.toString() == '_ShadowPainter');

  const params = PaperParams(tilt: 0.3, damping: 30);

  testWidgets('pressed at its right edge the sheet tilts, then springs back', (
    tester,
  ) async {
    await pump(tester, params: params);
    final box = tester.getRect(find.byType(PaperBubble));
    final gesture = await tester.startGesture(
      box.centerRight - const Offset(2, 0),
    );
    await frames(tester);
    expect(tiltY(tester), closeTo(-0.3, 0.02));

    await gesture.up();
    await frames(tester);
    expect(tiltY(tester), closeTo(0, 1e-3));
  });

  testWidgets('the content keeps its taps while the sheet tilts', (
    tester,
  ) async {
    var taps = 0;
    await pump(tester, params: params, onTap: () => taps++);
    await tester.tap(find.text('TAP'));
    await frames(tester);
    expect(taps, 1);
  });

  testWidgets('a drag on the sheet scrolls the list and lets the sheet go', (
    tester,
  ) async {
    await pump(tester, params: params);
    final before = tester.getTopLeft(find.byType(PaperBubble));
    final box = tester.getRect(find.byType(PaperBubble));
    final gesture = await tester.startGesture(
      box.centerRight - const Offset(4, 0),
    );
    await frames(tester);
    expect(tiltY(tester), lessThan(-0.1));

    for (var i = 0; i < 10; i++) {
      await gesture.moveBy(const Offset(0, -15));
      await tester.pump(const Duration(milliseconds: 16));
    }
    await frames(tester);
    expect(tester.getTopLeft(find.byType(PaperBubble)).dy, lessThan(before.dy));
    // Still held, but the sheet moved under the finger: flat again.
    expect(tiltY(tester), closeTo(0, 1e-3));
    await gesture.up();
  });

  testWidgets('no tilt without the flag or at 0', (tester) async {
    await pump(tester, params: params, tilt: false);
    expect(tiltTransforms(), findsNothing);

    await pump(tester, params: params.copyWith(tilt: 0));
    expect(tiltTransforms(), findsNothing);
  });

  testWidgets('a scrolling sheet tilts, and lets go when it scrolls', (
    tester,
  ) async {
    final controller = ScrollController();
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Center(
            child: SizedBox(
              width: 300,
              height: 400,
              child: PaperBubble(
                params: params,
                controller: controller,
                tilt: true,
                child: SingleChildScrollView(
                  controller: controller,
                  child: const SizedBox(height: 3000),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    final box = tester.getRect(find.byType(PaperBubble));
    final gesture = await tester.startGesture(
      box.centerRight - const Offset(4, 0),
    );
    await frames(tester);
    expect(tiltY(tester), lessThan(-0.1));

    for (var i = 0; i < 10; i++) {
      await gesture.moveBy(const Offset(0, -15));
      await tester.pump(const Duration(milliseconds: 16));
    }
    await frames(tester);
    expect(controller.offset, greaterThan(0));
    // Still held, but the content scrolled: flat again.
    expect(tiltY(tester), closeTo(0, 1e-3));
    await gesture.up();
  });

  testWidgets('the sheet casts a shadow unless its strength is 0', (
    tester,
  ) async {
    await pump(tester, params: params);
    expect(hasShadow(tester), isTrue);

    await pump(tester, params: params.copyWith(dropShadow: 0));
    expect(hasShadow(tester), isFalse);
  });

  testWidgets('a moving lamp or a tilt never rebuilds the content', (
    tester,
  ) async {
    var builds = 0;
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
                params: params,
                tilt: true,
                child: Builder(
                  builder: (context) {
                    builds++;
                    return const SizedBox(height: 200);
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    final before = builds;

    container
        .read(paperLightProvider.notifier)
        .set(const PaperLight(azimuth: 0.4, elevation: 1.2));
    await tester.pump();
    final box = tester.getRect(find.byType(PaperBubble));
    final gesture = await tester.startGesture(
      box.centerLeft + const Offset(4, 0),
    );
    await frames(tester);
    expect(tiltY(tester), greaterThan(0.1));
    await gesture.up();
    await frames(tester);
    expect(builds, before);
  });
}
