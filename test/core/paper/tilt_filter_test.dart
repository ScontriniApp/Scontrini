import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:scontrini/core/paper/tilt_filter.dart';

/// Gravity for a phone held upright, leaning back by [pitch] and with its
/// right edge down by [roll] (radians), [ms] milliseconds in.
GravitySample held({required int ms, double pitch = 0.6, double roll = 0}) {
  const g = 9.81;
  final x = math.sin(roll) * g;
  final rest = math.cos(roll) * g;
  return (
    x: x,
    y: math.cos(pitch) * rest,
    z: math.sin(pitch) * rest,
    time: DateTime(2026, 11, 26).add(Duration(milliseconds: ms)),
  );
}

/// Feeds 50 readings a second from [fromMs] to [toMs].
Offset feed(
  TiltFilter filter,
  int fromMs,
  int toMs, {
  double pitch = 0.6,
  double roll = 0,
}) {
  var tilt = filter.tilt;
  for (var ms = fromMs; ms <= toMs; ms += 20) {
    tilt = filter.add(held(pitch: pitch, roll: roll, ms: ms));
  }
  return tilt;
}

void main() {
  test('a phone held still has no tilt, whatever the holding angle', () {
    final filter = TiltFilter();
    expect(feed(filter, 0, 2000, pitch: 0.3), Offset.zero);
    expect(feed(TiltFilter(), 0, 2000, pitch: 1.2), Offset.zero);
  });

  test('tilting swings the light, signed by direction', () {
    final filter = TiltFilter();
    feed(filter, 0, 1000);
    final tilt = feed(filter, 1020, 1400, pitch: 0.9, roll: 0.2);
    // Mostly followed (smoothing 120 ms), not yet settled back (2.5 s).
    expect(tilt.dy, greaterThan(0.15));
    expect(tilt.dy, lessThan(0.3));
    expect(tilt.dx, greaterThan(0.08));

    final back = TiltFilter();
    feed(back, 0, 1000);
    final other = feed(back, 1020, 1400, pitch: 0.3, roll: -0.2);
    expect(other.dy, lessThan(-0.15));
    expect(other.dx, lessThan(-0.08));
  });

  test('held in the new pose, the light eases back to rest', () {
    final filter = TiltFilter();
    feed(filter, 0, 1000);
    final moved = feed(filter, 1020, 1400, pitch: 0.9);
    final later = feed(filter, 1420, 9000, pitch: 0.9);
    expect(later.dy.abs(), lessThan(moved.dy.abs() * 0.1));
  });

  test('a quick jolt is smoothed away', () {
    final filter = TiltFilter();
    feed(filter, 0, 1000);
    final tilt = filter.add(held(pitch: 1.6, ms: 1020));
    expect(tilt.dy, lessThan(0.2));
  });

  test('the tilt is clamped', () {
    final filter = TiltFilter(limit: 0.3);
    feed(filter, 0, 1000, pitch: 0.2);
    final tilt = feed(filter, 1020, 1600, pitch: 1.5);
    expect(tilt.dy, 0.3);
  });

  test('readings without gravity, or out of order, are ignored', () {
    final filter = TiltFilter();
    feed(filter, 0, 1000);
    final before = filter.tilt;
    final zero = (x: 0.0, y: 0.0, z: 0.0, time: DateTime(2026, 11, 27));
    expect(filter.add(zero), before);
    expect(filter.add(held(pitch: 1.4, ms: 500)), before);
  });

  test('reset makes the next reading the rest pose', () {
    final filter = TiltFilter();
    feed(filter, 0, 1000);
    feed(filter, 1020, 1400, pitch: 1.2);
    expect(filter.tilt, isNot(Offset.zero));
    filter.reset();
    expect(filter.tilt, Offset.zero);
    expect(filter.add(held(pitch: 1.2, ms: 2000)), Offset.zero);
  });
}
