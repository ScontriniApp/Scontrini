import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:scontrini/core/paper/tilt_filter.dart';
import 'package:sensors_plus/sensors_plus.dart';

/// Accelerometer readings, about 50 a second while someone listens.
/// Overridden in tests.
final gravityProvider = Provider<Stream<GravitySample>>(
  (ref) =>
      accelerometerEventStream(samplingPeriod: SensorInterval.gameInterval)
          .map((e) => (x: e.x, y: e.y, z: e.z, time: e.timestamp)),
);

/// Builds [builder] with how far the phone was just tilted (see
/// [TiltFilter.tilt]), for the paper's light.
///
/// Listens to the accelerometer only while [enabled] and the system's
/// "reduce motion" setting is off; otherwise the tilt is zero. Without a
/// sensor (desktop, tests) it stays zero too, and [onUnavailable] is called.
class PaperTilt extends ConsumerStatefulWidget {
  const new({
    required this.builder,
    this.enabled = true,
    this.onUnavailable,
    super.key,
  });

  final Widget Function(BuildContext context, Offset tilt) builder;
  final bool enabled;
  final VoidCallback? onUnavailable;

  @override
  ConsumerState<PaperTilt> createState() => _PaperTiltState();
}

class _PaperTiltState extends ConsumerState<PaperTilt> {
  final _filter = TiltFilter();
  StreamSubscription<GravitySample>? _subscription;
  Offset _tilt = Offset.zero;

  /// The sensor failed once: don't ask again (no sensor on this device).
  bool _unavailable = false;

  /// Smaller changes don't repaint (about 0.1°).
  static const _step = 0.002;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _sync();
  }

  @override
  void didUpdateWidget(PaperTilt oldWidget) {
    super.didUpdateWidget(oldWidget);
    _sync();
  }

  void _sync() {
    final listen =
        widget.enabled &&
        !_unavailable &&
        !MediaQuery.disableAnimationsOf(context);
    if (listen && _subscription == null) {
      _subscription = ref
          .read(gravityProvider)
          .listen(
            _onSample,
            onError: (Object _) {
              _unavailable = true;
              if (!mounted) return;
              setState(_stop);
              widget.onUnavailable?.call();
            },
            cancelOnError: true,
          );
    } else if (!listen && _subscription != null) {
      _stop();
    }
  }

  void _onSample(GravitySample sample) {
    final tilt = _filter.add(sample);
    if ((tilt - _tilt).distance >= _step) setState(() => _tilt = tilt);
  }

  /// Stops listening and puts the light back at rest. Callers in the
  /// lifecycle methods rebuild anyway; others wrap it in setState.
  void _stop() {
    unawaited(_subscription?.cancel());
    _subscription = null;
    _filter.reset();
    _tilt = Offset.zero;
  }

  @override
  void dispose() {
    unawaited(_subscription?.cancel());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.builder(context, _tilt);
}
