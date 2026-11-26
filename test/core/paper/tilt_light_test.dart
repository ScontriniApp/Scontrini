import 'dart:async';
import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:scontrini/core/paper/paper_params.dart';
import 'package:scontrini/core/paper/tilt_light.dart';

void main() {
  group('PaperLight.fromUp', () {
    test('phone flat on a table: light straight above', () {
      final light = PaperLight.fromUp(0, 0, 9.8)!;
      expect(light.elevation, closeTo(math.pi / 2, 1e-9));
    });

    test('phone upright: light from the top edge, never below the minimum', () {
      final light = PaperLight.fromUp(0, 9.8, 0)!;
      final (x, y, z) = light.direction;
      expect(x, closeTo(0, 1e-9));
      expect(y, lessThan(-0.9)); // up the screen
      expect(z, closeTo(math.sin(0.15), 1e-9));
    });

    test('phone tilted to the right: light from the left edge', () {
      // Right edge lowered: "up" points towards the left edge (−x).
      final (x, _, z) = PaperLight.fromUp(-5, 0, 8)!.direction;
      expect(x, lessThan(0));
      expect(z, greaterThan(0));
    });

    test('no reading (free fall) gives no light', () {
      expect(PaperLight.fromUp(0, 0, 0), isNull);
    });
  });

  test('TiltLight smooths readings and stops', () async {
    final readings = StreamController<(double, double, double)>();
    final lights = <PaperLight>[];
    final tilt = TiltLight(
      onLight: lights.add,
      readings: readings.stream,
      smoothing: 0.5,
    )..start();
    expect(tilt.running, isTrue);

    readings
      ..add((0, 0, 9.8))
      ..add((0, 9.8, 0));
    await Future<void>.delayed(Duration.zero);
    expect(lights, hasLength(2));
    // Halfway between flat and upright: about 45° up, not upright yet.
    expect(lights.last.elevation, closeTo(math.pi / 4, 1e-9));

    await tilt.stop();
    expect(tilt.running, isFalse);
    readings.add((0, 9.8, 0));
    await Future<void>.delayed(Duration.zero);
    expect(lights, hasLength(2));
    await readings.close();
  });
}
