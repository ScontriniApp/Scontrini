import 'dart:async';
import 'dart:isolate';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:scontrini/core/paper/fold_surface.dart';
import 'package:scontrini/core/paper/paper_params.dart';
import 'package:scontrini/core/paper/paper_settings.dart';
import 'package:scontrini/core/tilt/plate_motion.dart';
import 'package:scontrini/core/tilt/touch_tilt.dart';

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
/// The sheet casts a soft shadow on the surface under it, away from the
/// lamp ([PaperParams.dropShadow], [PaperParams.hover]), following its torn
/// ends and corners. With [tilt] it tilts under a finger and lifts like a
/// shelf label ([TouchTilt]): the printed sheet is moved as a finished
/// layer (a [RepaintBoundary]) and relit, so a frame of the tilt runs only
/// the print shader (no snapshot, no bake).
///
/// With [controller], [child] must contain the vertical scrollable it
/// drives; the sheet is as long as that content, and only the sides bleed:
/// the top and bottom are the viewport's edges, cut there, unless
/// [overscan] carries the paper past them.
class PaperBubble extends ConsumerStatefulWidget {
  const new({
    required this.params,
    required this.child,
    this.controller,
    this.light,
    this.onReady,
    this.hideUntilReady = false,
    this.overscan = EdgeInsets.zero,
    this.tilt = false,
    super.key,
  });

  /// Tilts and lifts under a finger ([PaperParams.tilt]). The content keeps
  /// its touches (buttons, sliders) and scrolls as before: the sheet lets go
  /// as soon as it scrolls ([controller]) or a list around it does.
  final bool tilt;

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

/// The baked material of the sheet (`paper_bake.frag`'s four passes), and
/// where it lies on the paper. No light in it: the print shader lights it.
class _Bake {
  new({
    required this.key,
    required this.images,
    required this.origin,
    required this.size,
    required this.reach,
  });

  final Object key;

  /// Surface (normal, fibres, age), offset (ray offset, ink, height),
  /// horizon A (+ occlusion), horizon B.
  final List<ui.Image> images;

  /// Paper point of the images' top-left corner, logical px.
  final Offset origin;

  /// Paper area the images cover, logical px.
  final Size size;

  /// Largest offset the offset image holds, logical px.
  final double reach;

  void dispose() {
    for (final image in images) {
      image.dispose();
    }
  }
}

/// How the sheet is lit right now: the lamp in the room ([screen]) and the
/// lamp and eye seen from the (maybe tilted) sheet.
@immutable
class _Lighting {
  const new({required this.screen, required this.light, required this.eye});

  /// Towards the lamp, screen frame (x right, y down, z to the viewer).
  final (double, double, double) screen;

  /// Towards the lamp, the sheet's frame.
  final (double, double, double) light;

  /// The eye relative to the sheet's centre, the sheet's frame.
  final (double, double, double) eye;

  @override
  bool operator ==(Object other) =>
      other is _Lighting &&
      other.screen == screen &&
      other.light == light &&
      other.eye == eye;

  @override
  int get hashCode => Object.hash(screen, light, eye);
}

class _PaperBubbleState extends ConsumerState<PaperBubble> {
  PaperPrograms? _programs;
  ui.FragmentShader? _live;
  ui.FragmentShader? _frame;

  /// One per bake pass: each keeps its uniforms until its image is drawn.
  List<ui.FragmentShader> _bakeShaders = const [];
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

  /// The light the paper is drawn with: the print repaints from it without
  /// re-snapshotting its content, so a moving lamp or a tilt is cheap.
  late final ValueNotifier<_Lighting> _lighting = ValueNotifier(
    _lightingFor(null),
  );

  /// The tilt's motion, once [TouchTilt] has built (null = flat).
  PlateMotion? _motion;

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
    for (final shader in _bakeShaders) {
      shader.dispose();
    }
    _map?.dispose();
    _bake?.dispose();
    _lighting.dispose();
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
    return Size(size.width, length);
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

  /// Bakes the sheet's material when anything it shows changed (never for
  /// the light: the print shader lights it per frame).
  void _ensureBake({
    required PaperPrograms programs,
    required Size sheet,
    required EdgeInsets bleed,
    required double dpr,
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
    // Even, so the half-size horizon images cover exactly the same area.
    final halfWidth = math.max(1, (area.width * k / 2).ceil());
    final halfHeight = math.max(1, (area.height * k / 2).ceil());
    final width = halfWidth * 2;
    final height = halfHeight * 2;
    final key = (
      programs.bake,
      map,
      _mapHeight,
      p,
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

    if (_bakeShaders.isEmpty) {
      _bakeShaders = [
        for (var i = 0; i < 4; i++) programs.bake.fragmentShader(),
      ];
    }
    ui.Image pass(int index) {
      final shader = _bakeShaders[index];
      // The horizon (passes 2, 3) is soft: half the resolution.
      final half = index >= 2;
      final w = half ? halfWidth : width;
      final h = half ? halfHeight : height;
      var i = 0;
      void set(double v) => shader.setFloat(i++, v);
      set(half ? k / 2 : k);
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
      set(cx);
      set(cy);
      set(cz);
      set(p.roughness);
      set(p.edge);
      set(p.pixel);
      set(p.inkFade);
      set(p.lines);
      set(p.dropout);
      shader.setImageSampler(0, map, filterQuality: FilterQuality.low);
      final recorder = ui.PictureRecorder();
      Canvas(recorder).drawRect(
        Rect.fromLTWH(0, 0, w.toDouble(), h.toDouble()),
        Paint()..shader = shader,
      );
      final picture = recorder.endRecording();
      // Drawn on the raster thread; the image is usable at once.
      final image = picture.toImageSync(w, h);
      picture.dispose();
      return image;
    }

    final images = [for (var i = 0; i < 4; i++) pass(i)];
    _bake?.dispose();
    _bake = _Bake(
      key: key,
      images: images,
      origin: origin,
      size: covered,
      reach: reach,
    );
  }

  /// The light for the sheet tilted by [motion] (null = flat).
  _Lighting _lightingFor(PlateMotion? motion) {
    final light = widget.light ?? ref.read<PaperLight>(paperLightProvider);
    final screen = light.direction;
    final eye = widget.params.camera;
    if (motion == null) {
      return _Lighting(screen: screen, light: screen, eye: eye);
    }
    return _Lighting(
      screen: screen,
      light: motion.toPlate(screen),
      eye: motion.toPlate(eye),
    );
  }

  void _relight() => _lighting.value = _lightingFor(_motion);

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
    // A new lamp relights the paper without rebuilding it (no new content
    // snapshot): the print repaints from [_lighting].
    ref.listen(paperLightProvider, (_, _) => _relight());
    // Its own layer: the shadow and the tilt move it without repainting
    // (re-snapshotting) the paper.
    final paper = RepaintBoundary(child: _buildPaper(context));
    final params = widget.params;
    final tilting = widget.tilt && params.tilt > 0;
    final bubble = TouchTilt(
      knobs: params,
      enabled: tilting,
      claim: false,
      letGo: widget.controller,
      builder: (context, motion, matrix) {
        _motion = tilting ? motion : null;
        // The lamp and the eye seen from the tilted sheet (every frame of
        // the tilt): only the print shader runs again.
        _relight();
        Widget tilted(Widget child) => tilting
            ? Transform(
                alignment: Alignment.center,
                transform: matrix,
                child: child,
              )
            : child;
        return Stack(
          clipBehavior: Clip.none,
          fit: StackFit.passthrough,
          children: [
            if (params.dropShadow > 0 && _size != null)
              Positioned.fill(
                child: IgnorePointer(
                  child: tilted(
                    CustomPaint(
                      painter: _ShadowPainter(
                        sheet: _sheet() ?? _size!,
                        scroll: _scroll,
                        window: _shadowWindow(),
                        params: params,
                        lighting: _lighting,
                        lift: motion.lift,
                        repaint: Listenable.merge([
                          widget.controller,
                          _lighting,
                        ]),
                      ),
                    ),
                  ),
                ),
              ),
            tilted(paper),
          ],
        );
      },
    );
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

  /// The part of a scrolling sheet whose shadow can be seen, in the
  /// bubble's coordinates: the paper is cut at [PaperBubble.overscan].
  /// Everything for a sheet that doesn't scroll.
  Rect? _shadowWindow() {
    final size = _size;
    if (widget.controller == null || size == null) return null;
    return Rect.fromLTRB(
      -_maxBleed,
      -widget.overscan.top,
      size.width + _maxBleed,
      size.height + widget.overscan.bottom,
    );
  }

  Widget _buildPaper(BuildContext context) {
    final programs = ref.watch(paperProgramProvider).value;
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
      for (final shader in [_live, _frame, ..._bakeShaders]) {
        shader?.dispose();
      }
      _live = programs.live.fragmentShader();
      _frame = programs.frame.fragmentShader();
      _bakeShaders = const [];
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
          light: _lighting.value.screen,
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
        paper: paperSheet ?? sheet,
        rowEye: widget.controller != null,
        top: _mapHeight * widget.params.depth,
        lighting: _lighting.value,
        params: widget.params,
        filter: print,
      );
      // When printing, _Printed binds sampler 0 to the content.
      if (!print) shader.setImageSampler(0, _blank);
      for (final (i, image) in bake.images.indexed) {
        shader.setImageSampler(i + 1, image, filterQuality: FilterQuality.low);
      }
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
            lighting: _lighting,
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
          repaint: Listenable.merge([scroll, _lighting]),
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

/// The sheet's outline in its own coordinates: [corner] rounded corners and
/// the torn top and bottom ends of `paper_print.frag` (teeth [torn] wide,
/// as deep as half that). Only the rows from [top] to [bottom] (a scrolling
/// sheet's visible part; the ends' teeth only where they show).
@visibleForTesting
Path paperOutline(
  Size sheet, {
  required double torn,
  required double corner,
  double top = double.negativeInfinity,
  double bottom = double.infinity,
}) {
  final from = math.max(0, top).toDouble();
  final to = math.min(sheet.height, bottom);
  if (to <= from || sheet.width <= 0) return Path();
  double tooth(double x) {
    if (torn <= 0) return 0;
    final f = x / torn - (x / torn).floorToDouble();
    return torn * 0.5 * ((f - 0.5).abs() * 2);
  }

  final xs = <double>[];
  if (torn > 0) {
    for (var x = 0.0; x < sheet.width; x += torn / 2) {
      xs.add(x);
    }
  } else {
    xs.add(0);
  }
  xs.add(sheet.width);
  final outline = Path()..moveTo(xs.first, math.max(tooth(xs.first), from));
  for (final x in xs.skip(1)) {
    outline.lineTo(x, math.max(tooth(x), from));
  }
  for (final x in xs.reversed) {
    outline.lineTo(x, math.min(sheet.height - tooth(x), to));
  }
  outline.close();
  if (corner <= 0) return outline;
  final rounded = Path()
    ..addRRect(
      RRect.fromRectAndRadius(Offset.zero & sheet, Radius.circular(corner)),
    );
  return Path.combine(PathOperation.intersect, outline, rounded);
}

/// The shadow the sheet casts on the surface under it: its outline, blurred,
/// pushed away from the lamp by how high the sheet sits (more while lifted,
/// as the plastic plates' shadow).
class _ShadowPainter extends CustomPainter {
  new({
    required this.sheet,
    required this.scroll,
    required this.window,
    required this.params,
    required this.lighting,
    required this.lift,
    super.repaint,
  });

  final Size sheet;

  /// The sheet's y at the bubble's top (read on every paint: scrolling).
  final double Function() scroll;

  /// Rows that can be seen, in the bubble's coordinates (null = all).
  final Rect? window;
  final PaperParams params;

  /// The lamp in the room (its screen direction): read on every paint.
  final ValueListenable<_Lighting> lighting;
  final double lift;

  @override
  void paint(Canvas canvas, Size size) {
    final y = scroll();
    final window = this.window;
    final outline = paperOutline(
      sheet,
      torn: params.torn,
      corner: params.corner,
      top: window == null ? double.negativeInfinity : window.top + y,
      bottom: window == null ? double.infinity : window.bottom + y,
    );
    final (lx, ly, lz) = lighting.value.screen;
    final height = params.hover + (lift - 1) * 120;
    final reach = height / math.max(lz, 0.25);
    canvas
      ..save()
      ..translate(-lx * reach, -ly * reach - y)
      ..drawPath(
        outline,
        Paint()
          ..color = Colors.black.withValues(alpha: params.dropShadow)
          ..maskFilter = MaskFilter.blur(
            BlurStyle.normal,
            Shadow.convertRadiusToSigma(params.dropBlur),
          ),
      )
      ..restore();
  }

  @override
  bool shouldRepaint(_ShadowPainter old) =>
      old.sheet != sheet ||
      old.window != window ||
      old.params != params ||
      old.lighting != lighting ||
      old.lift != lift;
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
  required Size paper,
  required bool rowEye,
  required double top,
  required _Lighting lighting,
  required PaperParams params,
  required bool filter,
}) {
  final p = params;
  final (lx, ly, lz) = lighting.light;
  final (ex, ey, ez) = lighting.eye;
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
  set(filter ? p.ink.index.toDouble() : 0);
  set(p.edge);
  set(p.torn);
  set(p.corner);
  set(filter ? 1 : 0);
  set(paper.width);
  set(paper.height);
  set(rowEye ? 1 : 0);
  set(top);
  set(lx);
  set(ly);
  set(lz);
  set(p.lightDistance);
  set(ex);
  set(ey);
  set(ez);
  // The room's exposure: a tilt changes the light on the sheet, not it.
  set(1 / math.max(lighting.screen.$3, 0.12));
  set(p.ambient);
  set(p.occlusion);
  set(p.shadow);
  set(p.softness);
  set(p.sheen);
  set(p.roughness);
  set(p.fibres);
  set(p.levels);
  set(p.pixel);
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
  required (double, double, double) light,
  required bool filter,
}) {
  final p = params;
  final (lx, ly, lz) = light;
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
    required this.lighting,
    super.child,
  });

  final ui.FragmentShader shader;
  final double pixelRatio;

  /// A new light repaints the print without a new snapshot of [child].
  final Listenable lighting;

  /// Sets the shader's uniforms (sampler 0 is bound here).
  final VoidCallback configure;

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _RenderPrinted(shader, pixelRatio, configure, lighting);

  @override
  void updateRenderObject(BuildContext context, _RenderPrinted object) {
    object
      ..shader = shader
      ..pixelRatio = pixelRatio
      ..configure = configure
      ..lighting = lighting
      ..markNeedsPaint();
  }
}

class _RenderPrinted extends RenderProxyBox {
  new(this.shader, this.pixelRatio, this.configure, this._lighting);

  ui.FragmentShader shader;
  double pixelRatio;
  VoidCallback configure;

  Listenable _lighting;

  Listenable get lighting => _lighting;

  set lighting(Listenable value) {
    if (value == _lighting) return;
    if (attached) {
      _lighting.removeListener(_relight);
      value.addListener(_relight);
    }
    _lighting = value;
  }

  /// The last snapshot, kept until the next one replaces it.
  ui.Image? _content;

  /// The content changed (or may have) since [_content] was taken.
  var _contentDirty = true;

  /// Inside [_relight]: this repaint is for the light alone.
  var _relighting = false;

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    _lighting.addListener(_relight);
  }

  @override
  void detach() {
    _lighting.removeListener(_relight);
    super.detach();
  }

  @override
  void dispose() {
    _content?.dispose();
    super.dispose();
  }

  /// Repaints for a new light: the same snapshot, new uniforms. A tilt or a
  /// moving lamp runs only the print shader.
  void _relight() {
    _relighting = true;
    markNeedsPaint();
    _relighting = false;
  }

  // Every other repaint comes from the content (a child below asked, its
  // layout changed) or from a rebuild: take a new snapshot.
  @override
  void markNeedsPaint() {
    if (!_relighting) _contentDirty = true;
    super.markNeedsPaint();
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
    var content = _content;
    if (_contentDirty || content == null) {
      content = _snapshot();
      _content?.dispose();
      _content = content;
      _contentDirty = false;
    }
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
