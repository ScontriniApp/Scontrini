import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:scontrini/core/paper/paper_bubble.dart';
import 'package:scontrini/core/plastic/plastic_params.dart';
import 'package:scontrini/core/plastic/plastic_settings.dart';
import 'package:scontrini/core/tilt/touch_tilt.dart';

/// The compiled `shaders/plastic_plate.frag`, loaded once.
final plasticProgramProvider = FutureProvider<ui.FragmentProgram>(
  (ref) => ui.FragmentProgram.fromAsset('shaders/plastic_plate.frag'),
);

/// [child] made into a hard plastic plate (a shelf label): a raised rim with
/// a rounded edge around a glossy, recessed screen, lit by the room's lamp
/// ([paperLightProvider]). Touched, it tilts towards the finger like a
/// Balatro card, lifts a little and shows its side wall; let go, it springs
/// back flat. A touch that starts on the plate is the plate's: the list
/// around it doesn't scroll, so tilting and scrolling never fight.
///
/// [child] should fill a rounded rectangle of [radius], with its screen
/// [screenInsets] in from the edges. The plastic is a light overlay painted
/// over [child] inside the plate's transform (multiply for shade, plus for
/// highlights), so it tilts, scrolls and clips with the plate. Only drawn
/// on Impeller; elsewhere (Skia, widget tests) the plate still tilts,
/// without the plastic light. The side wall and shadow paint outside the
/// plate's box.
///
/// The plate is drawn on the nearest [Overlay] ([OverlayPortal]), above
/// everything else on the page: its shadow falls on the cards around it and,
/// lifted, it covers them instead of sliding under them. A plate touched
/// comes to the top of the other plates. Inside a scrollable it is clipped
/// to the scrollable's viewport, as it would be in place, so it never paints
/// over an app bar or a navigation bar. In place stays an invisible copy of
/// [child] that gives the plate its size and takes the touches.
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

class _PlasticPlateState extends ConsumerState<PlasticPlate> {
  /// One shader per pass (multiply, plus, debug): each keeps its uniforms.
  List<ui.FragmentShader> _shaders = const [];
  ui.FragmentProgram? _program;

  /// Always showing: [OverlayPortalController.show] again brings the plate
  /// to the top.
  final OverlayPortalController _portal = OverlayPortalController()..show();

  /// The invisible copy of the child in place (the overlay's anchor).
  final GlobalKey _anchor = GlobalKey();

  @override
  void dispose() {
    for (final shader in _shaders) {
      shader.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final watched = ref.watch(plasticSettingsProvider);
    final p = widget.params ?? watched;
    final light = ref.watch(paperLightProvider);
    final program = ref.watch(plasticProgramProvider).value;
    final shape = BorderRadius.circular(widget.radius);
    final shade = program != null && PlasticPlate.canShade;
    if (shade && program != _program) {
      for (final shader in _shaders) {
        shader.dispose();
      }
      _shaders = [for (var i = 0; i < 3; i++) program.fragmentShader()];
      _program = program;
    }

    final tilt = TouchTilt(
      knobs: p,
      builder: (context, motion, matrix) {
        var face = widget.child;
        if (shade) {
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
                      light: motion.toPlate(light.direction),
                      view: motion.toPlate((0, 0, 1)),
                    ),
                  ),
                ),
              ),
            ],
          );
        }

        // The side wall: copies of the outline stacked behind the face
        // along the plate's normal, so tilting shows them as a solid edge.
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
        final height = p.thickness + p.rim + (motion.lift - 1) * 120;
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

        final plate = Stack(
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
        );
        if (Overlay.maybeOf(context) == null) return plate;
        return OverlayPortal.overlayChildLayoutBuilder(
          controller: _portal,
          overlayChildBuilder: (context, info) =>
              _onOverlay(context, info, plate),
          child: _Ghost(key: _anchor, child: widget.child),
        );
      },
    );
    return Listener(
      onPointerDown: (_) {
        if (_portal.isShowing) _portal.show();
      },
      child: tilt,
    );
  }

  /// [plate] where the copy in place is, clipped to the scrollable around it.
  Widget _onOverlay(
    BuildContext context,
    OverlayChildLayoutInfo info,
    Widget plate,
  ) {
    final size = info.childSize;
    final placed = Positioned(
      left: 0,
      top: 0,
      width: size.width,
      height: size.height,
      child: Transform(
        transform: info.childPaintTransform,
        child: IgnorePointer(child: plate),
      ),
    );
    final viewport = _viewport(context, info);
    if (viewport == null) return Stack(children: [placed]);
    return ClipRect(
      clipper: _RectClipper(viewport),
      child: Stack(clipBehavior: Clip.none, children: [placed]),
    );
  }

  /// The enclosing scrollable's box in the overlay's coordinates.
  Rect? _viewport(BuildContext context, OverlayChildLayoutInfo info) {
    final scrollable = Scrollable.maybeOf(context)?.context.findRenderObject();
    final anchor = _anchor.currentContext?.findRenderObject();
    if (scrollable is! RenderBox ||
        anchor is! RenderBox ||
        !scrollable.hasSize ||
        !anchor.attached) {
      return null;
    }
    final toOverlay = info.childPaintTransform.clone()
      ..multiply(scrollable.getTransformTo(anchor));
    return MatrixUtils.transformRect(toOverlay, Offset.zero & scrollable.size);
  }
}

class _RectClipper extends CustomClipper<Rect> {
  const new(this.rect);

  final Rect rect;

  @override
  Rect getClip(Size size) => rect;

  @override
  bool shouldReclip(_RectClipper old) => old.rect != rect;
}

/// Lays [child] out for its size but neither paints it nor lets it be
/// touched, read by accessibility or found by tests: the plate's footprint.
class _Ghost extends SingleChildRenderObjectWidget {
  const new({super.key, super.child});

  @override
  SingleChildRenderObjectElement createElement() => _GhostElement(this);

  @override
  RenderObject createRenderObject(BuildContext context) => _RenderGhost();
}

class _GhostElement extends SingleChildRenderObjectElement {
  new(_Ghost super.widget);

  @override
  void debugVisitOnstageChildren(ElementVisitor visitor) {}
}

class _RenderGhost extends RenderProxyBox {
  @override
  void paint(PaintingContext context, Offset offset) {}

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) =>
      false;

  @override
  void visitChildrenForSemantics(RenderObjectVisitor visitor) {}
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
