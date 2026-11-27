import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:scontrini/core/paper/paper_bubble.dart';
import 'package:scontrini/core/plastic/plastic_params.dart';
import 'package:scontrini/core/plastic/plastic_settings.dart';
import 'package:scontrini/core/plastic/plate_motion.dart';

/// The compiled `shaders/plastic_plate.frag`, loaded once.
final plasticProgramProvider = FutureProvider<ui.FragmentProgram>(
  (ref) => ui.FragmentProgram.fromAsset('shaders/plastic_plate.frag'),
);

/// [child] made into a hard plastic plate (a shelf label): a raised rim with
/// a rounded edge around a glossy, recessed screen, lit by the room's lamp
/// ([paperLightProvider]). Touched, it tilts towards the finger like a
/// Balatro card, lifts a little and shows its side wall; let go, it springs
/// back flat.
///
/// [child] should fill a rounded rectangle of [radius], with its screen
/// [screenInsets] in from the edges. The plastic is a light overlay painted
/// over [child] inside the plate's transform (multiply for shade, plus for
/// highlights), so it tilts, scrolls and clips with the plate. Only drawn
/// on Impeller; elsewhere (Skia, widget tests) the plate still tilts,
/// without the plastic light. The side wall and shadow paint outside the
/// plate's box: leave room.
class PlasticPlate extends ConsumerStatefulWidget {
  const new({
    required this.child,
    this.radius = 10,
    this.screenInsets = EdgeInsets.zero,
    this.screenRadius = 2,
    this.params,
    this.wallColour = const Color(0xFFD6D6D2),
    super.key,
  });

  final Widget child;
  final double radius;
  final EdgeInsets screenInsets;
  final double screenRadius;

  /// Overrides [plasticSettingsProvider].
  final PlasticParams? params;

  /// Colour of the plate's side wall.
  final Color wallColour;

  static bool get canShade => ui.ImageFilter.isShaderFilterSupported;

  @override
  ConsumerState<PlasticPlate> createState() => _PlasticPlateState();
}

class _PlasticPlateState extends ConsumerState<PlasticPlate>
    with SingleTickerProviderStateMixin {
  final PlateMotion _motion = PlateMotion();
  late final Ticker _ticker = createTicker(_tick);
  Duration? _last;

  /// One shader per pass (multiply, plus, debug): each keeps its uniforms.
  List<ui.FragmentShader> _shaders = const [];
  ui.FragmentProgram? _program;

  PlasticParams get _params =>
      widget.params ?? ref.read(plasticSettingsProvider);

  @override
  void dispose() {
    _ticker.dispose();
    for (final shader in _shaders) {
      shader.dispose();
    }
    super.dispose();
  }

  void _tick(Duration elapsed) {
    final last = _last;
    _last = elapsed;
    if (last == null) return;
    // At most 50 ms per frame: a stalled frame must not fling the plate.
    final dt = math.min((elapsed - last).inMicroseconds / 1e6, 0.05);
    final moving = _motion.step(dt, _params);
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

  void _touch(Offset local, {required bool pressed}) {
    final size = context.size;
    if (size == null || size.isEmpty) return;
    // A finger that slid off (scrolling the list) lets the plate go.
    if (!(Offset.zero & size).inflate(8).contains(local)) {
      _release();
      return;
    }
    _motion.touch(
      local.dx / size.width * 2 - 1,
      local.dy / size.height * 2 - 1,
      _params,
      pressed: pressed,
    );
    _wake();
  }

  void _release() {
    _motion.release();
    _wake();
  }

  /// The plate's transform: perspective, tilt, lift, about its centre.
  Matrix4 _transform(PlasticParams p) => Matrix4.identity()
    ..setEntry(3, 2, 1 / math.max(p.perspective, 100))
    ..rotateX(_motion.tiltX)
    ..rotateY(_motion.tiltY)
    ..scaleByDouble(_motion.lift, _motion.lift, 1, 1);

  @override
  Widget build(BuildContext context) {
    final watched = ref.watch(plasticSettingsProvider);
    final p = widget.params ?? watched;
    final light = ref.watch(paperLightProvider);
    final program = ref.watch(plasticProgramProvider).value;
    final matrix = _transform(p);
    final shape = BorderRadius.circular(widget.radius);

    var face = widget.child;
    if (program != null && PlasticPlate.canShade) {
      if (program != _program) {
        for (final shader in _shaders) {
          shader.dispose();
        }
        _shaders = [for (var i = 0; i < 3; i++) program.fragmentShader()];
        _program = program;
      }
      face = Stack(
        fit: StackFit.passthrough,
        children: [
          face,
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: _PlasticLight(
                  shaders: _shaders,
                  plate: widget,
                  params: p,
                  light: _motion.toPlate(light.direction),
                  view: _motion.toPlate((0, 0, 1)),
                ),
              ),
            ),
          ),
        ],
      );
    }

    // The side wall: copies of the outline stacked behind the face along
    // the plate's normal, so tilting shows them as a solid edge.
    final layers = math.min(8, math.max(1, p.thickness.ceil()));
    final wall = [
      for (var i = layers; i >= 1; i--)
        Positioned.fill(
          child: Transform(
            alignment: Alignment.center,
            transform: matrix.clone()
              ..translateByDouble(0, 0, p.thickness * i / layers, 1),
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: shape,
                color: Color.lerp(
                  widget.wallColour,
                  const Color(0xFF8E8E88),
                  0.15 + 0.35 * i / layers,
                ),
              ),
            ),
          ),
        ),
    ];

    // The shadow on the surface under the plate, away from the lamp and
    // further while it is lifted.
    final (lx, ly, lz) = light.direction;
    final height = p.thickness + p.rim + (_motion.lift - 1) * 120;
    final reach = height / math.max(lz, 0.25);
    // It follows the plate's tilt: the tilted outline, pushed along the
    // light on the table.
    final shadow = Positioned.fill(
      child: Transform(
        alignment: Alignment.center,
        transform: matrix,
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: shape,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: p.dropShadow),
                blurRadius: p.dropBlur,
                offset: Offset(-lx, -ly) * reach,
              ),
            ],
          ),
        ),
      ),
    );

    return Listener(
      behavior: HitTestBehavior.opaque,
      onPointerDown: (e) => _touch(e.localPosition, pressed: true),
      onPointerMove: (e) => _touch(e.localPosition, pressed: true),
      onPointerHover: (e) => _touch(e.localPosition, pressed: false),
      onPointerUp: (_) => _release(),
      onPointerCancel: (_) => _release(),
      child: MouseRegion(
        onExit: (_) => _release(),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            shadow,
            ...wall,
            Transform(
              alignment: Alignment.center,
              transform: matrix,
              child: face,
            ),
          ],
        ),
      ),
    );
  }
}

/// Paints the plastic light over the label in the plate's own coordinates.
class _PlasticLight extends CustomPainter {
  new({
    required this.shaders,
    required this.plate,
    required this.params,
    required this.light,
    required this.view,
  });

  final List<ui.FragmentShader> shaders;
  final PlasticPlate plate;
  final PlasticParams params;
  final (double, double, double) light;
  final (double, double, double) view;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    final rect = Offset.zero & size;
    final passes = params.debugView.index > 0
        ? const [(2, BlendMode.srcOver)]
        : const [(0, BlendMode.multiply), (1, BlendMode.plus)];
    for (final (pass, mode) in passes) {
      final shader = shaders[pass];
      _setUniforms(
        shader,
        size: size,
        plate: plate,
        params: params,
        light: light,
        view: view,
        pass: pass,
      );
      canvas.drawRect(
        rect,
        Paint()
          ..shader = shader
          ..blendMode = mode,
      );
    }
  }

  @override
  bool shouldRepaint(_PlasticLight old) =>
      old.params != params ||
      old.light != light ||
      old.view != view ||
      old.plate != plate ||
      old.shaders != shaders;
}

/// Uniform order of `plastic_plate.frag`.
void _setUniforms(
  ui.FragmentShader shader, {
  required Size size,
  required PlasticPlate plate,
  required PlasticParams params,
  required (double, double, double) light,
  required (double, double, double) view,
  required int pass,
}) {
  final p = params;
  final insets = plate.screenInsets;
  var i = 0;
  void set(double v) => shader.setFloat(i++, v);
  set(size.width);
  set(size.height);
  set(plate.radius);
  set(insets.left);
  set(insets.top);
  set(insets.right);
  set(insets.bottom);
  set(plate.screenRadius);
  set(p.rim);
  set(p.bevel);
  set(p.lip);
  set(p.recess);
  set(light.$1);
  set(light.$2);
  set(light.$3);
  set(view.$1);
  set(view.$2);
  set(view.$3);
  set(p.ambient);
  set(p.gloss);
  set(p.shininess);
  set(p.screenGloss);
  set(p.screenShininess);
  set(p.fresnel);
  set(p.reflection);
  set(p.grain);
  set(p.shadow);
  set(p.debugView.index.toDouble());
  set(pass.toDouble());
}
