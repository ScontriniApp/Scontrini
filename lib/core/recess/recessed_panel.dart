import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:scontrini/core/paper/paper_bubble.dart';
import 'package:scontrini/core/recess/recess_params.dart';
import 'package:scontrini/core/recess/recess_settings.dart';

/// The compiled `shaders/recessed_well.frag`, loaded once.
final recessProgramProvider = FutureProvider<ui.FragmentProgram>(
  (ref) => ui.FragmentProgram.fromAsset('shaders/recessed_well.frag'),
);

/// [child] inside a drawer carved into the app's background: walls going
/// down from a rounded edge to a floor [depth] below, lit by the room's
/// lamp ([paperLightProvider]), with the rim's shadow falling into it.
///
/// The well is seen in perspective from an eye above the screen
/// ([RecessParams.eyeX], [RecessParams.eyeY], [RecessParams.eyeDistance]),
/// so which walls show depends on where the drawer is: they change as the
/// list around it scrolls.
///
/// [child] floats [RecessParams.lift] above the floor: its text and icons
/// cast a soft shadow on it, away from the lamp. Ink splashes paint above
/// the floor (a transparent [Material] around [child]).
///
/// The well is a shader (Impeller only); elsewhere (Skia, widget tests) a
/// flat, slightly darker tray is drawn instead.
class RecessedPanel extends ConsumerStatefulWidget {
  const new({
    required this.child,
    this.depth,
    this.params,
    this.margin = const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
    super.key,
  });

  final Widget child;

  /// Overrides [RecessParams.depth] (a closing drawer animates it).
  final double? depth;

  /// Overrides [recessSettingsProvider].
  final RecessParams? params;

  /// Space around the opening.
  final EdgeInsets margin;

  static bool get canShade => ui.ImageFilter.isShaderFilterSupported;

  /// Shadow that content [RecessParams.lift] above a floor casts on it,
  /// away from [light] (towards the lamp, screen frame).
  static List<Shadow> contentShadows(
    (double, double, double) light,
    RecessParams params,
  ) {
    final (lx, ly, lz) = light;
    if (params.textShadow <= 0) return const [];
    final reach = params.lift / math.max(lz, 0.2);
    return [
      Shadow(
        color: Color.fromRGBO(0, 0, 0, params.textShadow.clamp(0, 1)),
        offset: Offset(-lx, -ly) * reach,
        blurRadius: params.textBlur + params.lift * 0.15,
      ),
    ];
  }

  @override
  ConsumerState<RecessedPanel> createState() => _RecessedPanelState();
}

class _RecessedPanelState extends ConsumerState<RecessedPanel> {
  ui.FragmentShader? _shader;
  ui.FragmentProgram? _program;

  /// Every scrollable above the drawer: when one moves, the walls change.
  Listenable? _scrolls;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final positions = <ScrollPosition>[];
    var scrollable = Scrollable.maybeOf(context);
    while (scrollable != null) {
      positions.add(scrollable.position);
      scrollable = Scrollable.maybeOf(scrollable.context);
    }
    _scrolls = positions.isEmpty ? null : Listenable.merge(positions);
  }

  @override
  void dispose() {
    _shader?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final watched = ref.watch(recessSettingsProvider);
    final p = widget.params ?? watched;
    final light = ref.watch(paperLightProvider).direction;
    final program = ref.watch(recessProgramProvider).value;
    final theme = Theme.of(context);
    if (program != null && RecessedPanel.canShade && program != _program) {
      _shader?.dispose();
      _shader = program.fragmentShader();
      _program = program;
    }
    final screen = MediaQuery.sizeOf(context);
    final shadows = RecessedPanel.contentShadows(light, p);
    final radius = BorderRadius.circular(p.radius);

    return Padding(
      padding: widget.margin,
      child: _Well(
        shader: RecessedPanel.canShade ? _shader : null,
        params: p,
        depth: widget.depth ?? p.depth,
        light: light,
        base: theme.scaffoldBackgroundColor,
        eye: Offset(screen.width * p.eyeX, screen.height * p.eyeY),
        scrolls: _scrolls,
        child: Material(
          type: MaterialType.transparency,
          borderRadius: radius,
          clipBehavior: Clip.antiAlias,
          child: Theme(
            data: theme.copyWith(
              textTheme: _shadowed(theme.textTheme, shadows),
            ),
            child: IconTheme.merge(
              data: IconThemeData(shadows: shadows),
              child: DefaultTextStyle.merge(
                style: TextStyle(shadows: shadows),
                child: widget.child,
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// The theme's text styles with [shadows]: they don't inherit from
  /// [DefaultTextStyle], so each one gets them.
  static TextTheme _shadowed(TextTheme t, List<Shadow> shadows) {
    TextStyle? s(TextStyle? style) => style?.copyWith(shadows: shadows);
    return TextTheme(
      displayLarge: s(t.displayLarge),
      displayMedium: s(t.displayMedium),
      displaySmall: s(t.displaySmall),
      headlineLarge: s(t.headlineLarge),
      headlineMedium: s(t.headlineMedium),
      headlineSmall: s(t.headlineSmall),
      titleLarge: s(t.titleLarge),
      titleMedium: s(t.titleMedium),
      titleSmall: s(t.titleSmall),
      bodyLarge: s(t.bodyLarge),
      bodyMedium: s(t.bodyMedium),
      bodySmall: s(t.bodySmall),
      labelLarge: s(t.labelLarge),
      labelMedium: s(t.labelMedium),
      labelSmall: s(t.labelSmall),
    );
  }
}

/// Paints the well behind its child.
class _Well extends SingleChildRenderObjectWidget {
  const new({
    required this.shader,
    required this.params,
    required this.depth,
    required this.light,
    required this.base,
    required this.eye,
    required this.scrolls,
    super.child,
  });

  final ui.FragmentShader? shader;
  final RecessParams params;
  final double depth;
  final (double, double, double) light;
  final Color base;
  final Offset eye;
  final Listenable? scrolls;

  @override
  RenderObject createRenderObject(BuildContext context) => _RenderWell()
    ..shader = shader
    ..params = params
    ..wellDepth = depth
    ..light = light
    ..base = base
    ..eye = eye
    ..scrolls = scrolls;

  @override
  void updateRenderObject(BuildContext context, _RenderWell renderObject) =>
      renderObject
        ..shader = shader
        ..params = params
        ..wellDepth = depth
        ..light = light
        ..base = base
        ..eye = eye
        ..scrolls = scrolls;
}

class _RenderWell extends RenderProxyBox {
  ui.FragmentShader? _shader;
  ui.FragmentShader? get shader => _shader;
  set shader(ui.FragmentShader? value) {
    if (value == _shader) return;
    _shader = value;
    markNeedsPaint();
  }

  RecessParams _params = const RecessParams();
  RecessParams get params => _params;
  set params(RecessParams value) {
    if (value == _params) return;
    _params = value;
    markNeedsPaint();
  }

  double _depth = 0;
  double get wellDepth => _depth;
  set wellDepth(double value) {
    if (value == _depth) return;
    _depth = value;
    markNeedsPaint();
  }

  (double, double, double) _light = (0, 0, 1);
  (double, double, double) get light => _light;
  set light((double, double, double) value) {
    if (value == _light) return;
    _light = value;
    markNeedsPaint();
  }

  Color _base = const Color(0xFFFFFFFF);
  Color get base => _base;
  set base(Color value) {
    if (value == _base) return;
    _base = value;
    markNeedsPaint();
  }

  /// The eye over the screen, global coordinates.
  Offset _eye = Offset.zero;
  Offset get eye => _eye;
  set eye(Offset value) {
    if (value == _eye) return;
    _eye = value;
    markNeedsPaint();
  }

  Listenable? _scrolls;
  Listenable? get scrolls => _scrolls;
  set scrolls(Listenable? value) {
    if (value == _scrolls) return;
    if (attached) _scrolls?.removeListener(markNeedsPaint);
    _scrolls = value;
    if (attached) _scrolls?.addListener(markNeedsPaint);
    markNeedsPaint();
  }

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    _scrolls?.addListener(markNeedsPaint);
  }

  @override
  void detach() {
    _scrolls?.removeListener(markNeedsPaint);
    super.detach();
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (!size.isEmpty) {
      final canvas = context.canvas;
      final shader = _shader;
      if (shader != null) {
        // Where the eye is, in the drawer's own coordinates.
        final eye = _eye - localToGlobal(Offset.zero);
        _setUniforms(shader, eye);
        canvas
          ..save()
          ..translate(offset.dx, offset.dy)
          ..drawRect(Offset.zero & size, Paint()..shader = shader)
          ..restore();
      } else {
        // No shader: a flat tray a shade darker than the background.
        final rrect = RRect.fromRectAndRadius(
          offset & size,
          Radius.circular(_params.radius),
        );
        canvas
          ..drawRRect(
            rrect,
            Paint()..color = Color.lerp(_base, const Color(0xFF000000), 0.06)!,
          )
          ..drawRRect(
            rrect.deflate(0.5),
            Paint()
              ..style = PaintingStyle.stroke
              ..color = Color.lerp(_base, const Color(0xFF000000), 0.18)!,
          );
      }
    }
    super.paint(context, offset);
  }

  /// Uniform order of `recessed_well.frag`.
  void _setUniforms(ui.FragmentShader shader, Offset eye) {
    final p = _params;
    var i = 0;
    void set(double v) => shader.setFloat(i++, v);
    set(size.width);
    set(size.height);
    set(p.radius);
    set(_depth);
    set(p.bevel);
    set(eye.dx);
    set(eye.dy);
    set(p.eyeDistance);
    set(_light.$1);
    set(_light.$2);
    set(_light.$3);
    set(_base.r);
    set(_base.g);
    set(_base.b);
    set(p.ambient);
    set(p.floorShade);
    set(p.wallShade);
    set(p.shadow);
    set(p.softness);
    set(p.occlusion);
    set(p.highlight);
    set(p.debugView.index.toDouble());
  }
}
