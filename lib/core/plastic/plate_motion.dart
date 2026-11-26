import 'dart:math' as math;

import 'package:scontrini/core/plastic/plastic_params.dart';

/// A damped spring towards a target: follows quickly, overshoots a little
/// when lightly damped (the wobble after a card is let go).
class Spring {
  new([this.value = 0]);

  double value;
  double velocity = 0;

  /// Advances [dt] seconds towards [target].
  void step(
    double dt,
    double target, {
    required double stiffness,
    required double damping,
  }) {
    // Small sub-steps keep stiff springs stable on slow frames.
    final steps = math.max(1, (dt / (1 / 240)).ceil());
    final h = dt / steps;
    for (var i = 0; i < steps; i++) {
      final force = stiffness * (target - value) - damping * velocity;
      velocity += force * h;
      value += velocity * h;
    }
  }

  bool restsAt(double target) =>
      (value - target).abs() < 1e-4 && velocity.abs() < 1e-3;

  void settle(double target) {
    value = target;
    velocity = 0;
  }
}

/// The plate's tilt under a finger, Balatro-card style: the touched side
/// sinks away from the eye, the plate lifts a little while held, and on
/// release it springs back flat (with a small wobble).
///
/// Angles are for `Matrix4.rotationX` / `rotationY` with +z away from the
/// viewer, as in Flutter's perspective transforms.
class PlateMotion {
  final Spring _x = Spring();
  final Spring _y = Spring();
  final Spring _lift = Spring(1);

  double _targetX = 0;
  double _targetY = 0;
  double _targetLift = 1;

  /// Rotation about the horizontal axis, radians.
  double get tiltX => _x.value;

  /// Rotation about the vertical axis, radians.
  double get tiltY => _y.value;

  /// Scale of the plate.
  double get lift => _lift.value;

  /// A finger (or pointer) at [nx], [ny] on the plate, each -1 (left / top
  /// edge) to 1 (right / bottom edge). [pressed] lifts the plate (a hover
  /// only tilts it).
  void touch(
    double nx,
    double ny,
    PlasticParams params, {
    bool pressed = true,
  }) {
    final x = nx.clamp(-1.0, 1.0);
    final y = ny.clamp(-1.0, 1.0);
    // Pressing the bottom pushes it away: positive rotation about x.
    // Pressing the right pushes it away: negative rotation about y.
    _targetX = y * params.tilt;
    _targetY = -x * params.tilt;
    _targetLift = pressed ? params.lift : 1;
  }

  /// The finger left: back to flat.
  void release() {
    _targetX = 0;
    _targetY = 0;
    _targetLift = 1;
  }

  /// Advances [dt] seconds; false once the plate is at rest.
  bool step(double dt, PlasticParams params) {
    for (final (spring, target) in [
      (_x, _targetX),
      (_y, _targetY),
      (_lift, _targetLift),
    ]) {
      spring.step(
        dt,
        target,
        stiffness: params.stiffness,
        damping: params.damping,
      );
    }
    final resting =
        _x.restsAt(_targetX) &&
        _y.restsAt(_targetY) &&
        _lift.restsAt(_targetLift);
    if (resting) {
      _x.settle(_targetX);
      _y.settle(_targetY);
      _lift.settle(_targetLift);
    }
    return !resting;
  }

  /// [direction] (x right, y down, z towards the viewer) seen from the
  /// tilted plate: the same vector in the plate's own frame.
  (double, double, double) toPlate((double, double, double) direction) {
    // Flutter's frame has +z away from the viewer.
    final (wx, wy, wz) = (direction.$1, direction.$2, -direction.$3);
    // The plate is rotated by Rx · Ry; undo with Ryᵀ · Rxᵀ.
    final cx = math.cos(tiltX);
    final sx = math.sin(tiltX);
    final ax = wx;
    final ay = cx * wy + sx * wz;
    final az = -sx * wy + cx * wz;
    final cy = math.cos(tiltY);
    final sy = math.sin(tiltY);
    final bx = cy * ax - sy * az;
    final by = ay;
    final bz = sy * ax + cy * az;
    return (bx, by, -bz);
  }
}
