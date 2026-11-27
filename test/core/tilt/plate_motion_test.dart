import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:scontrini/core/plastic/plastic_params.dart';
import 'package:scontrini/core/tilt/plate_motion.dart';

void main() {
  const params = PlasticParams();

  /// Runs [motion] for [seconds] at 60 fps; the largest |tiltY| seen.
  double run(PlateMotion motion, double seconds, [PlasticParams p = params]) {
    var peak = 0.0;
    for (var t = 0.0; t < seconds; t += 1 / 60) {
      motion.step(1 / 60, p);
      peak = motion.tiltY.abs() > peak ? motion.tiltY.abs() : peak;
    }
    return peak;
  }

  test('a spring reaches its target and settles', () {
    final spring = Spring();
    for (var i = 0; i < 120; i++) {
      spring.step(1 / 60, 1, stiffness: 200, damping: 20);
    }
    expect(spring.value, closeTo(1, 1e-3));
    expect(spring.restsAt(1), isTrue);
  });

  test('pressing the right edge pushes it away from the eye', () {
    final motion = PlateMotion()..touch(1, 0, params);
    run(motion, 1);
    expect(motion.tiltY, closeTo(-params.tilt, 1e-3));
    expect(motion.tiltX, closeTo(0, 1e-6));
    expect(motion.lift, closeTo(params.lift, 1e-3));

    // As the plate's transform does it: +z is away in Flutter.
    final matrix = Matrix4.identity()
      ..rotateX(motion.tiltX)
      ..rotateY(motion.tiltY);
    final right = depthOf(matrix, 100, 0);
    final left = depthOf(matrix, -100, 0);
    expect(right, greaterThan(0));
    expect(left, lessThan(0));
  });

  test('pressing the bottom edge pushes it away too', () {
    final motion = PlateMotion()..touch(0, 1, params);
    run(motion, 1);
    final matrix = Matrix4.identity()
      ..rotateX(motion.tiltX)
      ..rotateY(motion.tiltY);
    expect(depthOf(matrix, 0, 100), greaterThan(0));
  });

  test('touches past the edge are clamped, a hover does not lift', () {
    final motion = PlateMotion()..touch(5, -5, params, pressed: false);
    run(motion, 1);
    expect(motion.tiltY.abs(), closeTo(params.tilt, 1e-3));
    expect(motion.tiltX.abs(), closeTo(params.tilt, 1e-3));
    expect(motion.lift, closeTo(1, 1e-6));
  });

  test('released, a lightly damped plate wobbles past flat and stops', () {
    const loose = PlasticParams(damping: 6);
    final motion = PlateMotion()..touch(1, 0, loose);
    run(motion, 1, loose);
    motion.release();
    var crossed = false;
    for (var i = 0; i < 600; i++) {
      final moving = motion.step(1 / 60, loose);
      if (motion.tiltY > 1e-3) crossed = true;
      if (!moving) break;
    }
    expect(crossed, isTrue, reason: 'overshoots the other way');
    expect(motion.step(1 / 60, loose), isFalse);
    expect(motion.tiltY, 0);
    expect(motion.lift, 1);
  });

  test('flat, directions are unchanged; tilted, they turn with it', () {
    final motion = PlateMotion();
    final (x, y, z) = motion.toPlate((0.3, -0.4, 0.866));
    expect(x, closeTo(0.3, 1e-9));
    expect(y, closeTo(-0.4, 1e-9));
    expect(z, closeTo(0.866, 1e-9));

    motion.touch(1, 0, params);
    run(motion, 1);
    // The right edge went away, so the plate faces right: from the plate,
    // the eye is off to its left.
    final (vx, _, vz) = motion.toPlate((0, 0, 1));
    expect(vx, lessThan(0));
    expect(vz, lessThan(1));
  });
}

/// Depth (+z = away from the eye) of the point x, y after [m].
double depthOf(Matrix4 m, double x, double y) =>
    m.entry(2, 0) * x + m.entry(2, 1) * y + m.entry(2, 3);
