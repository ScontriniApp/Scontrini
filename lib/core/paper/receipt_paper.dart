import 'dart:ui' as ui;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:scontrini/core/paper/paper_params.dart';

/// The compiled `shaders/receipt_paper.frag`, loaded once.
final receiptPaperProgramProvider = FutureProvider<ui.FragmentProgram>(
  (ref) => ui.FragmentProgram.fromAsset('shaders/receipt_paper.frag'),
);

/// Ink colour of the text when it's drawn on top of the paper (no shader
/// ink), close to the shader's `kInk`.
const receiptInk = Color(0xFF211F29);

/// [child] printed on a sheet of crumpled thermal paper.
///
/// With shader ink ([PaperParams.ink], Impeller only), [child] is rendered
/// as dark text on white and the shader turns it into ink that follows the
/// creases. Otherwise the paper is painted behind [child]. Until the shader
/// has loaded, or if it fails to, [child] sits on plain paper colour.
class ReceiptPaper extends ConsumerWidget {
  const new({required this.params, required this.child, super.key});

  final PaperParams params;
  final Widget child;

  /// Whether this backend can print the text with the shader.
  static bool get canPrintInk => ui.ImageFilter.isShaderFilterSupported;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final program = ref.watch(receiptPaperProgramProvider).value;
    final text = _InkColour(colour: receiptInk, child: child);
    if (program == null) {
      return ColoredBox(color: const Color(0xFFFBF8EF), child: text);
    }
    final dpr = MediaQuery.devicePixelRatioOf(context);
    if (params.ink && canPrintInk) {
      return _PrintedInk(
        program: program,
        params: params,
        dpr: dpr,
        child: text,
      );
    }
    return CustomPaint(
      painter: _PaperPainter(program: program, params: params),
      child: text,
    );
  }
}

/// Text through the shader as an image filter: the engine binds the
/// rendered child and its size.
class _PrintedInk extends StatefulWidget {
  const new({
    required this.program,
    required this.params,
    required this.dpr,
    required this.child,
  });

  final ui.FragmentProgram program;
  final PaperParams params;
  final double dpr;
  final Widget child;

  @override
  State<_PrintedInk> createState() => _PrintedInkState();
}

class _PrintedInkState extends State<_PrintedInk> {
  late final ui.FragmentShader _shader = widget.program.fragmentShader();

  @override
  void dispose() {
    _shader.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // The filter works on the texture in physical pixels; the size uniform
    // is overwritten by the engine.
    _setUniforms(
      _shader,
      Size.zero,
      widget.params,
      printInk: true,
      pixelScale: widget.dpr,
    );
    return ImageFiltered(
      imageFilter: ui.ImageFilter.shader(_shader),
      // Opaque white so the filter gets the whole area, and ink = darkness.
      child: ColoredBox(
        color: Colors.white,
        child: _InkColour(colour: Colors.black, child: widget.child),
      ),
    );
  }
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

class _PaperPainter extends CustomPainter {
  new({required this.program, required this.params});

  final ui.FragmentProgram program;
  final PaperParams params;

  /// The shader always declares a sampler; paper-only mode never reads it.
  static final ui.Image _dummy = () {
    final recorder = ui.PictureRecorder();
    Canvas(
      recorder,
    ).drawRect(const Rect.fromLTWH(0, 0, 1, 1), Paint()..color = Colors.white);
    return recorder.endRecording().toImageSync(1, 1);
  }();

  @override
  void paint(Canvas canvas, Size size) {
    final shader = program.fragmentShader();
    _setUniforms(shader, size, params, printInk: false, pixelScale: 1);
    shader.setImageSampler(0, _dummy);
    canvas.drawRect(Offset.zero & size, Paint()..shader = shader);
    shader.dispose();
  }

  @override
  bool shouldRepaint(_PaperPainter old) =>
      old.params != params || old.program != program;
}

/// Uniform order of `receipt_paper.frag`.
void _setUniforms(
  ui.FragmentShader shader,
  Size size,
  PaperParams p, {
  required bool printInk,
  required double pixelScale,
}) {
  var i = 0;
  void set(double v) => shader.setFloat(i++, v);
  set(size.width);
  set(size.height);
  set(p.seed);
  set(p.cells);
  set(p.depth);
  set(p.fine);
  set(p.lightAngle);
  set(p.fibres);
  set(p.edge);
  set(p.levels);
  set(p.pixel * pixelScale);
  set(printInk ? 1 : 0);
  set(p.warp * pixelScale);
  set(p.inkFade);
  set(p.lines);
  set(p.dropout);
}
