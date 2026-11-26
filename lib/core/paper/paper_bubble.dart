import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:scontrini/core/paper/fold_surface.dart';
import 'package:scontrini/core/paper/paper_params.dart';
import 'package:scontrini/core/paper/paper_settings.dart';

/// The compiled `shaders/receipt_paper.frag`, loaded once.
final paperProgramProvider = FutureProvider<ui.FragmentProgram>(
  (ref) => ui.FragmentProgram.fromAsset('shaders/receipt_paper.frag'),
);

/// The light every paper bubble on screen is lit by right now: the saved
/// one ([paperSettingsProvider]), unless something live (the tilt light)
/// overrides it with [PaperLightNotifier.set]. Invalidate it to go back to
/// the saved light.
final paperLightProvider = NotifierProvider<PaperLightNotifier, PaperLight>(
  PaperLightNotifier.new,
);

class PaperLightNotifier extends Notifier<PaperLight> {
  @override
  PaperLight build() => ref.watch(paperSettingsProvider.select((s) => s.light));

  // A setter would read oddly at the call sites (`notifier.light = ...`).
  // ignore: use_setters_to_change_properties
  void set(PaperLight light) => state = light;
}

/// Ink colour of text printed on the paper, close to the shader's `kInk`.
const receiptInk = Color(0xFF211F29);

/// [child] printed on a sheet of folded paper.
///
/// The creases come from a [FoldSurface] the size of the sheet: of this
/// bubble or, with [controller], of the whole scrolled content, so the
/// creases scroll with it. With shader print ([PaperParams.ink], Impeller
/// only), [child] is rendered on white and the shader prints it on the
/// paper, bent and lit like the paper. Otherwise the paper is painted
/// behind [child].
///
/// The paper is drawn over a slightly larger area than the bubble, centred
/// on it, so ridges the camera's perspective pushes past the bubble's
/// edges stay visible instead of being cut. That bleed paints outside the
/// bubble's layout box: leave some room around it (or no clipping parent).
///
/// With [controller], [child] must contain the vertical scrollable it
/// drives; the sheet is as long as that content, and only the sides bleed
/// (the top and bottom are the viewport's edges, cut on purpose).
class PaperBubble extends ConsumerStatefulWidget {
  const new({
    required this.params,
    required this.child,
    this.controller,
    this.light,
    super.key,
  });

  final PaperParams params;
  final Widget child;
  final ScrollController? controller;

  /// Overrides [paperLightProvider].
  final PaperLight? light;

  /// Whether this backend can print the content with the shader.
  static bool get canPrint => ui.ImageFilter.isShaderFilterSupported;

  @override
  ConsumerState<PaperBubble> createState() => _PaperBubbleState();
}

class _PaperBubbleState extends ConsumerState<PaperBubble> {
  ui.FragmentShader? _shader;
  ui.FragmentProgram? _program;
  Size? _size;
  ui.Image? _map;

  /// Height of the map's 1.0, logical px.
  double _mapHeight = 0;

  /// Most a bubble bleeds on each side, logical px.
  static const double _maxBleed = 96;
  Object? _mapKey;
  int _mapRequest = 0;

  /// Keeps the content mounted (scroll position, slider state) when the
  /// paper switches between placeholder, filter and painter.
  final GlobalKey _contentKey = GlobalKey();

  @override
  void dispose() {
    _shader?.dispose();
    _map?.dispose();
    super.dispose();
  }

  void _onSize(Size size) {
    if (size == _size) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => _size = size);
    });
  }

  /// The sheet in logical px: the bubble, or the whole scrolled content.
  Size? _sheet() {
    final size = _size;
    if (size == null || size.isEmpty) return null;
    final controller = widget.controller;
    if (controller == null || controller.positions.length != 1) return size;
    final position = controller.position;
    if (!position.hasContentDimensions || !position.hasViewportDimension) {
      return size;
    }
    final length =
        position.maxScrollExtent -
        position.minScrollExtent +
        position.viewportDimension;
    return Size(size.width, length);
  }

  double _scroll() {
    final controller = widget.controller;
    if (controller == null || controller.positions.length != 1) return 0;
    final position = controller.position;
    if (!position.hasPixels || !position.hasContentDimensions) return 0;
    return position.pixels - position.minScrollExtent;
  }

  /// How far past the bubble's edges the folded sheet can be seen, logical
  /// px on each side: a point at height h, d from the eye's foot along an
  /// axis, shows d·h / (eye height − h) further out. Symmetric, so the
  /// bubble stays centred in the area.
  EdgeInsets _bleed() {
    final size = _size;
    if (size == null || size.isEmpty) return EdgeInsets.zero;
    final top = _mapHeight * widget.params.depth;
    final (cx, cy, cz) = widget.params.camera;
    double reach(double half, double eye) {
      // 2 px for the anti-aliased outline.
      if (top <= 0) return 2;
      final room = cz - top;
      if (room <= 1) return _maxBleed;
      return math.min((half + eye.abs()) * top / room + 2, _maxBleed);
    }

    final side = reach(size.width / 2, cx);
    final ends = widget.controller == null ? reach(size.height / 2, cy) : 0.0;
    return EdgeInsets.symmetric(horizontal: side, vertical: ends);
  }

  void _ensureMap(Size sheet) {
    final p = widget.params;
    // Whole pixels: sub-pixel layout changes keep the same creases.
    final key = (
      p.surfaceSeed,
      p.creases,
      p.crumple,
      p.sharpness,
      sheet.width.round(),
      sheet.height.round(),
    );
    if (key == _mapKey) return;
    _mapKey = key;
    final request = ++_mapRequest;
    final surface = FoldSurface.generate(
      width: sheet.width,
      length: sheet.height,
      seed: p.surfaceSeed,
      creases: p.creases,
      crumple: p.crumple,
      sharpness: p.sharpness,
    );
    final height = surface.maxHeight;
    ui.decodeImageFromPixels(
      surface.toRgba(),
      surface.columns,
      surface.rows,
      ui.PixelFormat.rgba8888,
      (image) {
        if (!mounted || request != _mapRequest) {
          image.dispose();
          return;
        }
        setState(() {
          _map?.dispose();
          _map = image;
          _mapHeight = height;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final program = ref.watch(paperProgramProvider).value;
    final shared = ref.watch(paperLightProvider);
    final light = widget.light ?? shared;
    final ink = widget.params.ink;
    final print = ink != PaperInk.off && PaperBubble.canPrint;

    // The content, in the colours it is printed with.
    final content = _SizeListener(
      key: _contentKey,
      onSize: _onSize,
      child: _InkColour(
        colour: print && ink == PaperInk.thermal ? Colors.black : receiptInk,
        child: widget.child,
      ),
    );
    if (program == null) {
      return ColoredBox(color: const Color(0xFFFBF8EF), child: content);
    }
    if (program != _program) {
      _shader?.dispose();
      _shader = program.fragmentShader();
      _program = program;
    }
    final shader = _shader!;
    final dpr = MediaQuery.devicePixelRatioOf(context);
    final bleed = _bleed();

    void configure({required double scale}) {
      final sheet = _sheet();
      if (sheet != null) _ensureMap(sheet);
      final bubble = _size ?? const Size(1, 1);
      _setUniforms(
        shader,
        area: bleed.inflateSize(bubble),
        margin: bleed.topLeft,
        sheet: sheet ?? const Size(1, 1),
        scroll: _scroll(),
        height: _map == null ? 0 : _mapHeight,
        scale: scale,
        params: widget.params,
        light: light,
        filter: print,
      );
      // In filter mode the engine binds sampler 0 to the content.
      if (!print) shader.setImageSampler(0, _blank);
      shader.setImageSampler(
        1,
        _map ?? _flat,
        filterQuality: FilterQuality.low,
      );
    }

    final scroll = widget.controller ?? const AlwaysStoppedAnimation(0);
    final padded = Padding(padding: bleed, child: content);
    if (print) {
      return _Bleed(
        margin: bleed,
        child: ListenableBuilder(
          listenable: scroll,
          builder: (context, child) {
            configure(scale: dpr);
            return ImageFiltered(
              // Bilinear: bent print stays smooth instead of stair-stepped.
              imageFilter: ui.ImageFilter.shader(
                shader,
                filterQuality: FilterQuality.low,
              ),
              child: child,
            );
          },
          // Opaque white, so the filter gets the whole area and the paper
          // shows through wherever nothing is drawn.
          child: ColoredBox(color: Colors.white, child: padded),
        ),
      );
    }
    return _Bleed(
      margin: bleed,
      child: CustomPaint(
        painter: _PaperPainter(
          shader: shader,
          repaint: scroll,
          configure: () => configure(scale: 1),
        ),
        child: padded,
      ),
    );
  }
}

/// White 1×1: paint mode never reads the content sampler, but it must be
/// bound.
final ui.Image _blank = _solid(const Color(0xFFFFFFFF));

/// Map of a flat sheet, used until the real one is decoded.
final ui.Image _flat = _solid(const Color(0xFF808080));

ui.Image _solid(Color colour) {
  final recorder = ui.PictureRecorder();
  Canvas(recorder)
      .drawRect(const Rect.fromLTWH(0, 0, 1, 1), Paint()..color = colour);
  return recorder.endRecording().toImageSync(1, 1);
}

class _PaperPainter extends CustomPainter {
  new({
    required this.shader,
    required this.configure,
    required Listenable repaint,
  }) : super(repaint: repaint);

  final ui.FragmentShader shader;
  final VoidCallback configure;

  @override
  void paint(Canvas canvas, Size size) {
    configure();
    canvas.drawRect(Offset.zero & size, Paint()..shader = shader);
  }

  // The painter is rebuilt with the bubble; uniforms may have changed.
  @override
  bool shouldRepaint(_PaperPainter old) => true;
}

/// Uniform order of `receipt_paper.frag`.
void _setUniforms(
  ui.FragmentShader shader, {
  required Size area,
  required Offset margin,
  required Size sheet,
  required double scroll,
  required double height,
  required double scale,
  required PaperParams params,
  required PaperLight light,
  required bool filter,
}) {
  final p = params;
  final (lx, ly, lz) = light.direction;
  final (cx, cy, cz) = p.camera;
  var i = 0;
  void set(double v) => shader.setFloat(i++, v);
  // uSize: the engine sets the same in filter mode.
  set(area.width * scale);
  set(area.height * scale);
  set(sheet.width * scale);
  set(sheet.height * scale);
  set(scroll * scale);
  set(scale);
  set(p.seed);
  set(p.depth);
  set(height * scale);
  set(lx);
  set(ly);
  set(lz);
  set(p.lightDistance * scale);
  set(cx * scale);
  set(cy * scale);
  set(cz * scale);
  set(p.ambient);
  set(p.occlusion);
  set(p.shadow);
  set(p.softness);
  set(p.sheen);
  set(p.roughness);
  set(p.fibres);
  set(p.edge);
  set(p.levels);
  set(p.pixel * scale);
  set(filter ? p.ink.index.toDouble() : 0);
  set(p.inkFade);
  set(p.lines);
  set(p.dropout);
  set(p.torn * scale);
  set(p.corner * scale);
  set(p.debugView.index.toDouble());
  set(filter ? 1 : 0);
  set(margin.dx * scale);
  set(margin.dy * scale);
}

/// Paints all text and icons below in [colour], whatever the theme: in dark
/// mode the theme's text styles are white, which would print nothing.
class _InkColour extends StatelessWidget {
  const new({required this.colour, required this.child});

  final Color colour;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Theme(
      data: theme.copyWith(
        textTheme: theme.textTheme.apply(
          bodyColor: colour,
          displayColor: colour,
        ),
        iconTheme: theme.iconTheme.copyWith(color: colour),
      ),
      child: DefaultTextStyle.merge(
        style: TextStyle(color: colour),
        child: IconTheme.merge(
          data: IconThemeData(color: colour),
          child: child,
        ),
      ),
    );
  }
}

/// Reports its size after every layout.
class _SizeListener extends SingleChildRenderObjectWidget {
  const new({required this.onSize, super.key, super.child});

  final ValueChanged<Size> onSize;

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _RenderSizeListener(onSize);

  @override
  void updateRenderObject(
    BuildContext context,
    _RenderSizeListener renderObject,
  ) => renderObject.onSize = onSize;
}

class _RenderSizeListener extends RenderProxyBox {
  new(this.onSize);

  ValueChanged<Size> onSize;

  @override
  void performLayout() {
    super.performLayout();
    onSize(size);
  }
}

/// Lays [child] out [margin] larger than itself on each side and paints it
/// centred over its own box: the paper's bleed area, which may draw past
/// the bubble without taking layout room. Only the bubble's own box takes
/// hits.
class _Bleed extends SingleChildRenderObjectWidget {
  const new({required this.margin, super.child});

  final EdgeInsets margin;

  @override
  RenderObject createRenderObject(BuildContext context) => _RenderBleed(margin);

  @override
  void updateRenderObject(BuildContext context, _RenderBleed renderObject) =>
      renderObject.margin = margin;
}

class _RenderBleed extends RenderProxyBox {
  new(this._margin);

  EdgeInsets _margin;

  EdgeInsets get margin => _margin;

  set margin(EdgeInsets value) {
    if (value == _margin) return;
    _margin = value;
    markNeedsLayout();
  }

  Offset get _shift => -_margin.topLeft;

  BoxConstraints _inner(BoxConstraints c) => BoxConstraints(
    minWidth: c.minWidth + _margin.horizontal,
    maxWidth: c.maxWidth + _margin.horizontal,
    minHeight: c.minHeight + _margin.vertical,
    maxHeight: c.maxHeight + _margin.vertical,
  );

  Size _outer(BoxConstraints c, Size inner) => c.constrain(
    Size(
      math.max(0, inner.width - _margin.horizontal),
      math.max(0, inner.height - _margin.vertical),
    ),
  );

  @override
  void performLayout() {
    final child = this.child;
    if (child == null) {
      size = constraints.smallest;
      return;
    }
    child.layout(_inner(constraints), parentUsesSize: true);
    size = _outer(constraints, child.size);
  }

  @override
  Size computeDryLayout(BoxConstraints constraints) {
    final child = this.child;
    if (child == null) return constraints.smallest;
    return _outer(constraints, child.getDryLayout(_inner(constraints)));
  }

  double _less(double value, double by) => math.max(0, value - by);

  @override
  double computeMinIntrinsicWidth(double height) => _less(
    super.computeMinIntrinsicWidth(height + _margin.vertical),
    _margin.horizontal,
  );

  @override
  double computeMaxIntrinsicWidth(double height) => _less(
    super.computeMaxIntrinsicWidth(height + _margin.vertical),
    _margin.horizontal,
  );

  @override
  double computeMinIntrinsicHeight(double width) => _less(
    super.computeMinIntrinsicHeight(width + _margin.horizontal),
    _margin.vertical,
  );

  @override
  double computeMaxIntrinsicHeight(double width) => _less(
    super.computeMaxIntrinsicHeight(width + _margin.horizontal),
    _margin.vertical,
  );

  @override
  void paint(PaintingContext context, Offset offset) {
    final child = this.child;
    if (child != null) context.paintChild(child, offset + _shift);
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    final child = this.child;
    if (child == null) return false;
    return result.addWithPaintOffset(
      offset: _shift,
      position: position,
      hitTest: (result, transformed) =>
          child.hitTest(result, position: transformed),
    );
  }

  @override
  void applyPaintTransform(RenderBox child, Matrix4 transform) =>
      transform.translateByDouble(_shift.dx, _shift.dy, 0, 1);
}
