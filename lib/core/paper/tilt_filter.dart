import 'dart:math' as math;
import 'dart:ui' show Offset;

/// One accelerometer reading: gravity (plus hand shake) in the phone's axes
/// (x to the right of the screen, y to its top, z out of it), in m/s².
typedef GravitySample = ({double x, double y, double z, DateTime time});

/// Turns accelerometer readings into how far the phone was just tilted, for
/// the paper's light.
///
/// Gravity is smoothed twice: quickly, to drop the jitter, and slowly, to
/// follow the way the phone is being held. The tilt is the angle between the
/// two, so a movement swings the light and, held still, it eases back to
/// rest whatever the holding angle.
class TiltFilter {
  new({
    this.smoothing = const Duration(milliseconds: 120),
    this.settle = const Duration(milliseconds: 2500),
    this.limit = 0.6,
  });

  /// Time constant of the fast smoothing (jitter).
  final Duration smoothing;

  /// Time constant of the rest pose: how long the light takes to settle back
  /// once the phone is held still.
  final Duration settle;

  /// Largest tilt reported, in radians, either way.
  final double limit;

  ({double x, double y, double z})? _fast;
  ({double x, double y, double z})? _rest;
  DateTime? _last;

  /// The tilt as (roll, pitch) in radians: x > 0 when the phone's right edge
  /// went down, y > 0 when its top edge went back (away from the user).
  Offset get tilt {
    final fast = _fast;
    final rest = _rest;
    if (fast == null || rest == null) return Offset.zero;
    return Offset(
      _clamp(_wrap(_roll(fast) - _roll(rest))),
      _clamp(_wrap(_pitch(fast) - _pitch(rest))),
    );
  }

  /// Adds a reading and returns the new [tilt]. Readings with no gravity
  /// (free fall, a broken sensor) are ignored.
  Offset add(GravitySample sample) {
    final length = math.sqrt(
      sample.x * sample.x + sample.y * sample.y + sample.z * sample.z,
    );
    if (length < 1) return tilt;
    final g = (
      x: sample.x / length,
      y: sample.y / length,
      z: sample.z / length,
    );

    final last = _last;
    if (last == null || _fast == null || _rest == null) {
      _last = sample.time;
      _fast = g;
      _rest = g;
      return tilt;
    }
    final dt = sample.time.difference(last).inMicroseconds / 1e6;
    if (dt <= 0) return tilt;
    _last = sample.time;
    _fast = _towards(_fast!, g, dt, smoothing);
    _rest = _towards(_rest!, g, dt, settle);
    return tilt;
  }

  /// Forgets the readings: the next one is the new rest pose.
  void reset() {
    _fast = null;
    _rest = null;
    _last = null;
  }

  static ({double x, double y, double z}) _towards(
    ({double x, double y, double z}) from,
    ({double x, double y, double z}) to,
    double dt,
    Duration tau,
  ) {
    final seconds = tau.inMicroseconds / 1e6;
    final k = seconds <= 0 ? 1.0 : 1 - math.exp(-dt / seconds);
    return (
      x: from.x + (to.x - from.x) * k,
      y: from.y + (to.y - from.y) * k,
      z: from.z + (to.z - from.z) * k,
    );
  }

  // Right edge down: gravity moves towards +x.
  static double _roll(({double x, double y, double z}) g) =>
      math.atan2(g.x, math.sqrt(g.y * g.y + g.z * g.z));

  // Top edge back: the screen faces up more, gravity moves from y to z.
  static double _pitch(({double x, double y, double z}) g) =>
      math.atan2(g.z, g.y);

  static double _wrap(double a) {
    var v = a;
    while (v > math.pi) {
      v -= 2 * math.pi;
    }
    while (v < -math.pi) {
      v += 2 * math.pi;
    }
    return v;
  }

  double _clamp(double v) => v.clamp(-limit, limit);
}
