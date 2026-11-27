import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/scheduler.dart';
import 'package:material_ui/material_ui.dart';
import 'package:scontrini/core/tilt/plate_motion.dart';

/// Builds the tilted surface: [motion] for the light (`toPlate`) and the
/// lift, [transform] to apply about the centre (`Alignment.center`).
typedef TiltBuilder = Widget Function(
  BuildContext context,
  PlateMotion motion,
  Matrix4 transform,
);

/// A surface that tilts towards the finger like a Balatro card, lifts a
/// little while held and springs back flat when let go ([PlateMotion]).
///
/// [builder] runs on every frame of the motion: keep the expensive part a
/// widget built outside it (the same instance every frame), behind a
/// [RepaintBoundary] inside the transform, so a frame only moves a layer.
///
/// With [claim], a touch that starts on the surface is the surface's: a list
/// around it doesn't scroll and nothing inside gets it (shelf labels, which
/// have no taps). Without, the surface only watches the pointer: buttons and
/// sliders inside keep working, and it lets go as soon as it moves under the
/// finger (the list around it scrolled) or [letGo] fires (its own content
/// scrolled).
class TouchTilt extends StatefulWidget {
  const new({
    required this.knobs,
    required this.builder,
    this.enabled = true,
    this.claim = true,
    this.letGo,
    super.key,
  });

  final TiltKnobs knobs;
  final TiltBuilder builder;

  /// Off: flat, no pointer watched.
  final bool enabled;
  final bool claim;

  /// While a finger is down, a notification here lets the surface go until
  /// the finger lifts: a scroll inside the surface (a scrolling sheet's
  /// controller), where the surface itself doesn't move on screen.
  final Listenable? letGo;

  /// The transform for [motion]: perspective, tilt, lift, about the centre.
  static Matrix4 transformOf(PlateMotion motion, TiltKnobs knobs) =>
      Matrix4.identity()
        ..setEntry(3, 2, 1 / math.max(knobs.perspective, 100))
        ..rotateX(motion.tiltX)
        ..rotateY(motion.tiltY)
        ..scaleByDouble(motion.lift, motion.lift, 1, 1);

  @override
  State<TouchTilt> createState() => _TouchTiltState();
}

class _TouchTiltState extends State<TouchTilt>
    with SingleTickerProviderStateMixin {
  final PlateMotion _motion = PlateMotion();
  late final Ticker _ticker = createTicker(_tick);
  Duration? _last;

  /// Where the surface was on screen when the finger went down (without
  /// [TouchTilt.claim]): if it moves, a list scrolled it.
  Offset? _origin;

  /// The finger is down but no longer tilts (the surface moved under it).
  var _ignoring = false;

  /// A finger is down on the surface.
  var _pressed = false;

  @override
  void initState() {
    super.initState();
    widget.letGo?.addListener(_onLetGo);
  }

  @override
  void didUpdateWidget(TouchTilt old) {
    super.didUpdateWidget(old);
    if (old.letGo != widget.letGo) {
      old.letGo?.removeListener(_onLetGo);
      widget.letGo?.addListener(_onLetGo);
    }
    if (!widget.enabled && old.enabled) _release();
  }

  @override
  void dispose() {
    widget.letGo?.removeListener(_onLetGo);
    _ticker.dispose();
    super.dispose();
  }

  void _onLetGo() {
    if (!_pressed || _ignoring) return;
    _ignoring = true;
    _release();
  }

  void _tick(Duration elapsed) {
    final last = _last;
    _last = elapsed;
    if (last == null) return;
    // At most 50 ms per frame: a stalled frame must not fling the surface.
    final dt = math.min((elapsed - last).inMicroseconds / 1e6, 0.05);
    final moving = _motion.step(dt, widget.knobs);
    setState(() {});
    if (!moving) {
      _ticker.stop();
      _last = null;
    }
  }

  void _wake() {
    if (!_ticker.isActive) {
      _last = null;
      _ticker.start();
    }
  }

  Offset? _screenOrigin() {
    final box = context.findRenderObject();
    return box is RenderBox && box.attached
        ? box.localToGlobal(Offset.zero)
        : null;
  }

  void _down(Offset local) {
    _pressed = true;
    _ignoring = false;
    _origin = widget.claim ? null : _screenOrigin();
    _touch(local, pressed: true);
  }

  void _move(Offset local) {
    if (_ignoring) return;
    final origin = _origin;
    if (origin != null) {
      final now = _screenOrigin();
      if (now != null && (now - origin).distance > 4) {
        _ignoring = true;
        _release();
        return;
      }
    }
    _touch(local, pressed: true);
  }

  void _touch(Offset local, {required bool pressed}) {
    final size = context.size;
    if (size == null || size.isEmpty) return;
    // A finger that slid off lets the surface go.
    if (!(Offset.zero & size).inflate(8).contains(local)) {
      _release();
      return;
    }
    _motion.touch(
      local.dx / size.width * 2 - 1,
      local.dy / size.height * 2 - 1,
      widget.knobs,
      pressed: pressed,
    );
    _wake();
  }

  void _release() {
    _motion.release();
    _wake();
  }

  void _up() {
    _pressed = false;
    _origin = null;
    _ignoring = false;
    _release();
  }

  @override
  Widget build(BuildContext context) {
    final surface = widget.builder(
      context,
      _motion,
      TouchTilt.transformOf(_motion, widget.knobs),
    );
    if (!widget.enabled) return surface;

    Widget watched = Listener(
      behavior: HitTestBehavior.opaque,
      onPointerDown: (e) => _down(e.localPosition),
      onPointerMove: (e) => _move(e.localPosition),
      onPointerHover: (e) => _touch(e.localPosition, pressed: false),
      onPointerUp: (_) => _up(),
      onPointerCancel: (_) => _up(),
      child: MouseRegion(onExit: (_) => _release(), child: surface),
    );
    if (widget.claim) {
      // Claims every touch that starts on it at once, so a scrollable
      // around it loses the gesture; the Listener still follows the finger.
      watched = RawGestureDetector(
        behavior: HitTestBehavior.opaque,
        gestures: {
          EagerGestureRecognizer:
              GestureRecognizerFactoryWithHandlers<EagerGestureRecognizer>(
                EagerGestureRecognizer.new,
                (_) {},
              ),
        },
        child: watched,
      );
    }
    return watched;
  }
}
