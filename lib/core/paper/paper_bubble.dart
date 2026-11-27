import 'dart:async';
import 'dart:isolate';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:scontrini/core/paper/fold_surface.dart';
import 'package:scontrini/core/paper/paper_params.dart';
import 'package:scontrini/core/paper/paper_settings.dart';

/// The paper's shaders, compiled once.
@immutable
class PaperPrograms {
  const new({required this.live, required this.bake, required this.frame});

  /// `shaders/receipt_paper.frag`: the whole scene on every frame. Only the
  /// lab's debug views (normals, height, light) use it.
  final ui.FragmentProgram live;

  /// `shaders/paper_bake.frag`: the lit sheet, once per change.
  final ui.FragmentProgram bake;

  /// `shaders/paper_print.frag`: the baked sheet and the print, per frame.
  final ui.FragmentProgram frame;
}

/// The paper's shaders, loaded once.
final paperProgramProvider = FutureProvider<PaperPrograms>((ref) async {
  final [live, bake, frame] = await Future.wait([
    ui.FragmentProgram.fromAsset('shaders/receipt_paper.frag'),
    ui.FragmentProgram.fromAsset('shaders/paper_bake.frag'),
    ui.FragmentProgram.fromAsset('shaders/paper_print.frag'),
  ]);
  return PaperPrograms(live: live, bake: bake, frame: frame);
});

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
/// The lit sheet is baked: the expensive scene (relief seen through a
/// perspective camera, lamp, cast shadows, occlusion, grain) is drawn once
/// into two images when the paper, the lamp or the sheet change, and each
/// frame only reads them and prints the content. A live lamp (the tilt
/// light) re-bakes on every change. A scrolling sheet grows in blocks of
/// [sheetBlock], so content that grows a little (a row's buttons) keeps
/// its creases and its bake. The fold map is built on a background isolate
/// ([backgroundMaps]).
///
/// The paper is drawn over a slightly larger area than the bubble, centred
/// on it, so ridges the camera's perspective pushes past the bubble's
/// edges stay visible instead of being cut. That bleed paints outside the
/// bubble's layout box: leave some room around it (or no clipping parent).
///
/// With [controller], [child] must contain the vertical scrollable it
/// drives; the sheet is as long as that content (torn off a little before
/// its end, within [tailBlank]), and only the sides bleed: the top and
/// bottom are the viewport's edges, cut there, unless [overscan] carries
/// the paper past them.
class PaperBubble extends ConsumerStatefulWidget {
  const new({
    required this.params,
    required this.child,
    this.controller,
    this.light,
    this.onReady,
    this.hideUntilReady = false,
    this.overscan = EdgeInsets.zero,
    super.key,
  });

  /// With [controller]: how far the paper and its print reach past the
  /// viewport's top and bottom ([EdgeInsets.top] and [EdgeInsets.bottom];
  /// the sides bleed anyway). The folds make the paper show print from a
  /// little beyond where it is drawn, so at a cut edge the print stops
  /// short and leaves a blank band; past the edge it reads on. Put the cut
  /// where it is hidden (under an app bar) or out of the way. The
  /// scrollable must not clip (`clipBehavior: Clip.none`), so the print is
  /// there to read; nothing is drawn past [overscan].
  final EdgeInsets overscan;

  final PaperParams params;
  final Widget child;
  final ScrollController? controller;

  /// Overrides [paperLightProvider].
  final PaperLight? light;

  /// Called once, after the first frame that shows the finished paper (its
  /// creases decoded and the sheet baked), so a screen can keep a loading
  /// cover up until then.
  final VoidCallback? onReady;

  /// Keeps the content invisible (laid out, not painted) until the paper is
  /// ready, at most [readyTimeout]: no flash of unprinted content.
  final bool hideUntilReady;

  /// The longest [hideUntilReady] hides the content.
  static const readyTimeout = Duration(seconds: 3);

  /// Whether this backend can print the content with the shader.
  static bool get canPrint => ui.ImageFilter.isShaderFilterSupported;

  /// Whether fold maps are built on a background isolate. Widget tests turn
  /// it off: their fake clock never sees the isolate's answer.
  static bool backgroundMaps = true;

  /// A scrolling sheet's length grows in steps of this many logical px.
  static const double sheetBlock = 512;

  /// Blank a scrolling sheet's content must end with: the sheet is torn
  /// off up to this far before the content's end, so a fold near the end
  /// can't push the torn edge out of view.
  static const double tailBlank = 24;

  /// Whether readiness waits for the shaders, the creases and the bake.
  /// Widget tests turn it off (their fake clock never loads them): every
  /// bubble is ready at once.
  static bool waitForPaper = true;

  @override
  ConsumerState<PaperBubble> createState() => _PaperBubbleState();
}

/// A fold map, as the isolate hands it back.
typedef _MapData = ({Uint8List rgba, int columns, int rows, double height});

/// What a fold map is built from (sendable to an isolate).
typedef _MapSpec = ({
  double width,
  double length,
  int seed,
  double creases,
  double crumple,
  double sharpness,
});

_MapData _buildMap(_MapSpec spec) {
  final surface = FoldSurface.generate(
    width: spec.width,
    length: spec.length,
    seed: spec.seed,
    creases: spec.creases,
    crumple: spec.crumple,
    sharpness: spec.sharpness,
  );
  return (
    rgba: surface.toRgba(),
    columns: surface.columns,
    rows: surface.rows,
    height: surface.maxHeight,
  );
}

// Top level, so the isolate's closure captures nothing but the spec.
Future<_MapData> _buildMapInBackground(_MapSpec spec) =>
    Isolate.run(() => _buildMap(spec));

/// The baked sheet: lit colour and the ray's offset + ink, and where they
/// lie on the paper.
class _Bake {
  new({
    required this.key,
    required this.colour,
    required this.offset,
    required this.origin,
    required this.size,
    required this.reach,
  });

  final Object key;
  final ui.Image colour;
  final ui.Image offset;

  /// Paper point of the images' top-left corner, logical px.
  final Offset origin;

  /// Paper area the images cover, logical px.
  final Size size;

  /// Largest offset the offset image holds, logical px.
  final double reach;

  void dispose() {
    colour.dispose();
    offset.dispose();
  }
}

class _PaperBubbleState extends ConsumerState<PaperBubble> {
  PaperPrograms? _programs;
  ui.FragmentShader? _live;
  ui.FragmentShader? _frame;
  ui.FragmentShader? _bakeColour;
  ui.FragmentShader? _bakeOffset;
  Size? _size;
  ui.Image? _map;

  /// The sheet [_map] was made for, logical px.
  Size? _mapSheet;

  /// Height of the map's 1.0, logical px.
  double _mapHeight = 0;

  /// Most a bubble bleeds on each side, logical px.
  static const double _maxBleed = 96;

  /// Baked images: at most this many px on a side, and in all.
  static const int _maxBakeSide = 8192;
  static const double _maxBakePixels = 4000000;

  Object? _mapKey;
  int _mapRequest = 0;
  _Bake? _bake;

  /// The content's length last seen, to repaint when it changes.
  double? _contentLength;

  /// Keeps the content mounted (scroll position, slider state) when the
  /// paper switches between placeholder, filter and painter.
  final GlobalKey _contentKey = GlobalKey();

  /// [PaperBubble.onReady] was called.
  var _reported = false;

  /// [PaperBubble.readyTimeout] passed: show the content whatever happens.
  var _timedOut = false;
  Timer? _timeout;

  @override
  void initState() {
    super.initState();
    if (widget.hideUntilReady && PaperBubble.waitForPaper) {
      _timeout = Timer(PaperBubble.readyTimeout, () {
        if (mounted) setState(() => _timedOut = true);
      });
    }
  }

  @override
  void dispose() {
    _timeout?.cancel();
    _live?.dispose();
    _frame?.dispose();
    _bakeColour?.dispose();
    _bakeOffset?.dispose();
    _map?.dispose();
    _bake?.dispose();
    super.dispose();
  }

  void _onSize(Size size) {
    if (size == _size) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => _size = size);
    });
  }

  /// The content grew or shrank without scrolling (a row's buttons): the
  /// torn end moves, maybe the sheet's block.
  bool _onMetrics(ScrollMetricsNotification notification) {
    final length = _sheet()?.height;
    if (length != null && length != _contentLength) {
      _contentLength = length;
      if (SchedulerBinding.instance.schedulerPhase ==
          SchedulerPhase.persistentCallbacks) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) setState(() {});
        });
      } else {
        setState(() {});
      }
    }
    return false;
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
    return Size(size.width, math.max(1, length - _tailRoom()));
  }

  /// How far above the content's end a scrolling sheet is torn off.
  ///
  /// Seen by the tilted camera, a valley in the paper shows further from
  /// the eye than where it lies: with the eye below the row, the torn
  /// bottom shows lower than the content's end, past the bubble's bottom,
  /// and was cut there when a fold happened to fall at the end. Tearing it
  /// this much earlier keeps the whole edge in view: |eye y| · h / (eye
  /// height − h) for the deepest point h, plus the outline. The content
  /// must end with at least [PaperBubble.tailBlank] of blank (its padding).
  double _tailRoom() {
    final top = _mapHeight * widget.params.depth;
    if (top <= 0) return 0;
    final (_, cy, cz) = widget.params.camera;
    final room = cz - top;
    if (room <= 1) return PaperBubble.tailBlank;
    return math.min(cy.abs() * top / room + 2, PaperBubble.tailBlank);
  }

  /// The sheet the creases and the bake are made for: [sheet], or for a
  /// scrolling sheet its length rounded up to a whole block.
  Size _blockOf(Size sheet) {
    if (widget.controller == null) return sheet;
    const block = PaperBubble.sheetBlock;
    final blocks = math.max(1, (sheet.height / block - 1e-6).ceil());
    return Size(sheet.width, blocks * block);
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
    if (widget.controller != null) {
      return EdgeInsets.fromLTRB(
        side,
        widget.overscan.top,
        side,
        widget.overscan.bottom,
      );
    }
    final ends = reach(size.height / 2, cy);
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
    final spec = (
      width: sheet.width,
      length: sheet.height,
      seed: p.surfaceSeed,
      creases: p.creases,
      crumple: p.crumple,
      sharpness: p.sharpness,
    );
    void decode(_MapData data) {
      if (!mounted || request != _mapRequest) return;
      ui.decodeImageFromPixels(
        data.rgba,
        data.columns,
        data.rows,
        ui.PixelFormat.rgba8888,
        (image) {
          if (!mounted || request != _mapRequest) {
            image.dispose();
            return;
          }
          setState(() {
            _map?.dispose();
            _map = image;
            _mapSheet = sheet;
            _mapHeight = data.height;
          });
        },
      );
    }

    if (PaperBubble.backgroundMaps) {
      unawaited(_buildMapInBackground(spec).then(decode));
    } else {
      decode(_buildMap(spec));
    }
  }

  /// Bakes the lit sheet when anything it shows changed.
  void _ensureBake({
    required PaperPrograms programs,
    required Size sheet,
    required EdgeInsets bleed,
    required double dpr,
    required PaperLight light,
  }) {
    final p = widget.params;
    final map = _map ?? _flat;
    final rowEye = widget.controller != null;
    final area = bleed.inflateSize(sheet);
    // Sharp enough for the grain, not more than the screen needs.
    final k = [
      math.min(dpr, 1.5),
      _maxBakeSide / area.width,
      _maxBakeSide / area.height,
      math.sqrt(_maxBakePixels / (area.width * area.height)),
    ].reduce(math.min);
    final width = math.max(1, (area.width * k).ceil());
    final height = math.max(1, (area.height * k).ceil());
    final key = (
      programs.bake,
      map,
      _mapHeight,
      p,
      light,
      sheet,
      bleed,
      width,
      height,
      rowEye,
    );
    if (_bake?.key == key) return;

    final (cx, cy, cz) = p.camera;
    final top = _mapHeight * p.depth;
    // The farthest a camera ray lands from its point: |xy| · h / eye height.
    final x = sheet.width / 2 + bleed.left + cx.abs();
    final y = rowEye ? cy.abs() : sheet.height / 2 + bleed.top + cy.abs();
    final reach = top <= 0
        ? 1.0
        : top * math.sqrt(x * x + y * y) / math.max(cz, 1) + 1;
    final origin = Offset(-bleed.left, -bleed.top);
    final covered = Size(width / k, height / k);

    ui.Image pass(ui.FragmentShader shader, int index) {
      final (lx, ly, lz) = light.direction;
      var i = 0;
      void set(double v) => shader.setFloat(i++, v);
      set(k);
      set(origin.dx);
      set(origin.dy);
      set(sheet.width);
      set(sheet.height);
      set(rowEye ? 1 : 0);
      set(index.toDouble());
      set(reach);
      set(p.seed);
      set(p.depth);
      set(_mapHeight);
      set(lx);
      set(ly);
      set(lz);
      set(p.lightDistance);
      set(cx);
      set(cy);
      set(cz);
      set(p.ambient);
      set(p.occlusion);
      set(p.shadow);
      set(p.softness);
      set(p.sheen);
      set(p.roughness);
      set(p.fibres);
      set(p.edge);
      set(p.levels);
      set(p.pixel);
      set(p.inkFade);
      set(p.lines);
      set(p.dropout);
      shader.setImageSampler(0, map, filterQuality: FilterQuality.low);
      final recorder = ui.PictureRecorder();
      Canvas(recorder).drawRect(
        Rect.fromLTWH(0, 0, width.toDouble(), height.toDouble()),
        Paint()..shader = shader,
      );
      final picture = recorder.endRecording();
      // Drawn on the raster thread; the image is usable at once.
      final image = picture.toImageSync(width, height);
      picture.dispose();
      return image;
    }

    final colour = pass(_bakeColour ??= programs.bake.fragmentShader(), 0);
    final offset = pass(_bakeOffset ??= programs.bake.fragmentShader(), 1);
    _bake?.dispose();
    _bake = _Bake(
      key: key,
      colour: colour,
      offset: offset,
      origin: origin,
      size: covered,
      reach: reach,
    );
  }

  /// Reports [PaperBubble.onReady] once, after the frame that shows it.
  void _reportReady() {
    if (_reported) return;
    _reported = true;
    _timeout?.cancel();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) widget.onReady?.call();
    });
  }

  @override
  Widget build(BuildContext context) {
    final bubble = _buildPaper(context);
    final ready =
        !PaperBubble.waitForPaper ||
        (_programs != null &&
            _map != null &&
            (widget.params.debugView != PaperDebugView.result ||
                _bake != null));
    if (ready || _timedOut) _reportReady();
    return Visibility(
      visible: ready || _timedOut || !widget.hideUntilReady,
      maintainSize: true,
      maintainAnimation: true,
      maintainState: true,
      child: bubble,
    );
  }

  Widget _buildPaper(BuildContext context) {
    final programs = ref.watch(paperProgramProvider).value;
    final shared = ref.watch(paperLightProvider);
    final light = widget.light ?? shared;
    final ink = widget.params.ink;
    final print = ink != PaperInk.off && PaperBubble.canPrint;

    // The content, in the colours it is printed with.
    final content = NotificationListener<ScrollMetricsNotification>(
      onNotification: _onMetrics,
      child: _SizeListener(
        key: _contentKey,
        onSize: _onSize,
        child: _InkColour(
          colour: print && ink == PaperInk.thermal ? Colors.black : receiptInk,
          child: widget.child,
        ),
      ),
    );
    if (programs == null) {
      return ColoredBox(color: const Color(0xFFFBF8EF), child: content);
    }
    if (programs != _programs) {
      for (final shader in [_live, _frame, _bakeColour, _bakeOffset]) {
        shader?.dispose();
      }
      _live = programs.live.fragmentShader();
      _frame = programs.frame.fragmentShader();
      _bakeColour = null;
      _bakeOffset = null;
      _bake?.dispose();
      _bake = null;
      _programs = programs;
    }
    final dpr = MediaQuery.devicePixelRatioOf(context);
    final bleed = _bleed();
    final target = _sheet();
    if (target != null) _ensureMap(_blockOf(target));
    // The sheet the creases and bake cover (the map's, once decoded).
    final paperSheet = _mapSheet ?? (target == null ? null : _blockOf(target));
    final live = widget.params.debugView != PaperDebugView.result;
    if (!live && paperSheet != null) {
      _ensureBake(
        programs: programs,
        sheet: paperSheet,
        bleed: bleed,
        dpr: dpr,
        light: light,
      );
    }
    final bake = _bake;
    final shader = live || bake == null ? _live! : _frame!;

    // Both shaders draw in the bubble's local, logical coordinates; the
    // print shader's uScale (device pixels) only sharpens its outline.
    void configure() {
      final sheet = _sheet() ?? const Size(1, 1);
      final bubble = _size ?? const Size(1, 1);
      final area = bleed.inflateSize(bubble);
      if (live || bake == null) {
        _setLiveUniforms(
          shader,
          area: area,
          margin: bleed.topLeft,
          sheet: paperSheet ?? sheet,
          scroll: _scroll(),
          height: _map == null ? 0 : _mapHeight,
          scale: 1,
          params: widget.params,
          light: light,
          filter: print,
        );
        if (!print) shader.setImageSampler(0, _blank);
        shader.setImageSampler(
          1,
          _map ?? _flat,
          filterQuality: FilterQuality.low,
        );
        return;
      }
      _setFrameUniforms(
        shader,
        area: area,
        scale: dpr,
        margin: bleed.topLeft,
        sheet: sheet,
        scroll: _scroll(),
        bake: bake,
        params: widget.params,
        filter: print,
      );
      // When printing, _Printed binds sampler 0 to the content.
      if (!print) shader.setImageSampler(0, _blank);
      shader
        ..setImageSampler(1, bake.colour, filterQuality: FilterQuality.low)
        ..setImageSampler(2, bake.offset, filterQuality: FilterQuality.low);
    }

    final scroll = widget.controller ?? const AlwaysStoppedAnimation(0);
    // Clipped to the bleed area: a scrollable that doesn't clip (for
    // [PaperBubble.overscan]) paints no further than the paper.
    final padded = ClipRect(
      child: Padding(padding: bleed, child: content),
    );
    if (print) {
      return _Bleed(
        margin: bleed,
        child: ListenableBuilder(
          listenable: scroll,
          builder: (context, child) => _Printed(
            shader: shader,
            pixelRatio: dpr,
            configure: configure,
            child: child,
          ),
          // Opaque white, so the snapshot covers the whole area and the
          // paper shows through wherever nothing is drawn.
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
          configure: configure,
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

/// Uniform order of `paper_print.frag`.
void _setFrameUniforms(
  ui.FragmentShader shader, {
  required Size area,
  required double scale,
  required Offset margin,
  required Size sheet,
  required double scroll,
  required _Bake bake,
  required PaperParams params,
  required bool filter,
}) {
  var i = 0;
  void set(double v) => shader.setFloat(i++, v);
  set(area.width);
  set(area.height);
  set(scale);
  set(margin.dx);
  set(margin.dy);
  set(sheet.width);
  set(sheet.height);
  set(scroll);
  set(bake.origin.dx);
  set(bake.origin.dy);
  set(bake.size.width);
  set(bake.size.height);
  set(bake.reach);
  set(filter ? params.ink.index.toDouble() : 0);
  set(params.edge);
  set(params.torn);
  set(params.corner);
  set(filter ? 1 : 0);
}

/// Uniform order of `receipt_paper.frag`.
void _setLiveUniforms(
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

/// [child] printed by the paper shader: the content is rendered into an
/// image on every paint (on white, the whole area, whatever clips are
/// around), then the shader draws the paper and the print from it on this
/// box's canvas, in its own coordinates. An ImageFilter was used before:
/// the engine fed it only the part its clips let through, and when it cut
/// changed with its own thresholds, so a paper half out of a list jumped
/// and its print smeared at the edge.
///
/// [child] repaints reach this box only if nothing between them is a
/// repaint boundary.
class _Printed extends SingleChildRenderObjectWidget {
  const new({
    required this.shader,
    required this.pixelRatio,
    required this.configure,
    super.child,
  });

  final ui.FragmentShader shader;
  final double pixelRatio;

  /// Sets the shader's uniforms (sampler 0 is bound here).
  final VoidCallback configure;

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _RenderPrinted(shader, pixelRatio, configure);

  @override
  void updateRenderObject(BuildContext context, _RenderPrinted object) {
    object
      ..shader = shader
      ..pixelRatio = pixelRatio
      ..configure = configure
      ..markNeedsPaint();
  }
}

class _RenderPrinted extends RenderProxyBox {
  new(this.shader, this.pixelRatio, this.configure);

  ui.FragmentShader shader;
  double pixelRatio;
  VoidCallback configure;

  /// The last snapshot, kept until the next one replaces it.
  ui.Image? _content;

  @override
  void dispose() {
    _content?.dispose();
    super.dispose();
  }

  ui.Image _snapshot() {
    final layer = OffsetLayer();
    final context = PaintingContext(layer, Offset.zero & size);
    super.paint(context, Offset.zero);
    // As SnapshotWidget does: the recording must be closed before the
    // layer is rasterised.
    // ignore: invalid_use_of_protected_member
    context.stopRecordingIfNeeded();
    final image = layer.toImageSync(Offset.zero & size, pixelRatio: pixelRatio);
    layer.dispose();
    return image;
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (child == null || size.isEmpty) return;
    final content = _snapshot();
    _content?.dispose();
    _content = content;
    configure();
    shader.setImageSampler(0, content, filterQuality: FilterQuality.low);
    // Translated, so FlutterFragCoord is this box's own position.
    context.canvas
      ..save()
      ..translate(offset.dx, offset.dy)
      ..drawRect(Offset.zero & size, Paint()..shader = shader)
      ..restore();
  }
}
