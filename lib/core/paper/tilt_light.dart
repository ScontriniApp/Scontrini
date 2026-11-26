import 'dart:async';

import 'package:scontrini/core/paper/paper_params.dart';
import 'package:sensors_plus/sensors_plus.dart';

/// Keeps the paper light coming from above in the room: wherever the phone
/// points, the light comes from the real "up".
///
/// "Up" is the opposite of gravity, read from the accelerometer (the
/// gyroscope alone measures turning, not where up is) and smoothed so hand
/// tremor doesn't flicker the creases.
class TiltLight {
  new({
    required this.onLight,
    Stream<(double, double, double)>? readings,
    this.smoothing = 0.15,
  }) : _readings = readings ?? _accelerometer();

  /// Called with the new light after every reading.
  final void Function(PaperLight light) onLight;

  /// Weight of a new reading in the running average (1 = no smoothing).
  final double smoothing;

  final Stream<(double, double, double)> _readings;
  StreamSubscription<(double, double, double)>? _subscription;
  (double, double, double)? _up;

  bool get running => _subscription != null;

  void start() {
    if (running) return;
    _up = null;
    _subscription = _readings.listen(_onReading);
  }

  Future<void> stop() async {
    await _subscription?.cancel();
    _subscription = null;
  }

  void _onReading((double, double, double) reading) {
    final previous = _up;
    final a = smoothing;
    final up = previous == null
        ? reading
        : (
            previous.$1 + (reading.$1 - previous.$1) * a,
            previous.$2 + (reading.$2 - previous.$2) * a,
            previous.$3 + (reading.$3 - previous.$3) * a,
          );
    _up = up;
    final light = PaperLight.fromUp(up.$1, up.$2, up.$3);
    if (light != null) onLight(light);
  }

  static Stream<(double, double, double)> _accelerometer() =>
      accelerometerEventStream(samplingPeriod: SensorInterval.gameInterval)
          .map((e) => (e.x, e.y, e.z));
}
