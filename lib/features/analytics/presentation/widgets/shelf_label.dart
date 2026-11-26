import 'dart:math';

import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';
import 'package:qr/qr.dart';
import 'package:scontrini/core/plastic/plastic_params.dart';
import 'package:scontrini/core/plastic/plastic_plate.dart';
import 'package:scontrini/core/utils/money.dart';

/// An electronic shelf label: white plastic frame around a grey e-ink
/// screen with a lightly scratched cover. On the screen: [title] in
/// capitals, then [leading] top left, the price of [cents] (big euros,
/// small cents and "€") and a QR code, [corner] under [leading], and
/// [footer] along the bottom.
///
/// The label is a physical object, so it keeps its colours in dark mode.
/// With [plastic] (the default) it is a hard plastic [PlasticPlate]: raised
/// rim, glossy screen, tilting under a finger, with the look saved in the
/// plastic lab (`plasticSettingsProvider`).
class ShelfLabel extends StatelessWidget {
  const new({
    required this.title,
    required this.cents,
    required this.leading,
    required this.footer,
    this.corner,
    this.plastic = true,
    this.plasticParams,
    super.key,
  });

  final String title;
  final int cents;
  final String leading;
  final String footer;
  final Widget? corner;

  /// Whether the label is a [PlasticPlate] (lit, tilting, with its own
  /// shadow) or a flat drawing with a soft shadow.
  final bool plastic;

  /// Overrides the saved plastic look (the lab's debug views).
  final PlasticParams? plasticParams;

  /// Corner radius of the plastic frame.
  static const frameRadius = 10.0;

  /// Where the screen sits inside the frame.
  static const screenInsets = EdgeInsets.fromLTRB(12, 10, 12, 16);

  /// Corner radius of the screen.
  static const screenRadius = 2.0;

  static const _frame = Color(0xFFF5F5F3);
  static const _frameEdge = Color(0xFFD9D9D6);
  static const _screen = Color(0xFFD3D3CE);

  /// The e-ink colour, for text and icons placed on the label.
  static const ink = Color(0xFF1C1D1A);

  /// What the label's QR code opens when scanned.
  static const qrLink = 'https://youtu.be/dQw4w9WgXcQ?si=T2WgO4j0cNmCg5pH';

  static final _qr = QrImage(
    QrCode(
      payload: QrPayload.fromString(qrLink),
      errorCorrectLevel: QrErrorCorrectLevel.low,
    ),
  );

  /// The small print on the label.
  static TextStyle? smallStyle(BuildContext context) =>
      Theme.of(context).textTheme.bodyMedium
          ?.copyWith(color: ink, height: 0.95);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final locale = Localizations.localeOf(context).toString();
    final number = NumberFormat.decimalPattern(locale);
    final euros = '${cents < 0 ? '-' : ''}${number.format(cents.abs() ~/ 100)}';
    final small = smallStyle(context);
    final corner = this.corner;

    final label = Container(
      padding: screenInsets,
      decoration: BoxDecoration(
        color: _frame,
        borderRadius: BorderRadius.circular(frameRadius),
        border: Border.all(color: _frameEdge),
        boxShadow: [
          // The plate casts its own shadow, following the lamp.
          if (!plastic)
            const BoxShadow(
              color: Color(0x1F000000),
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
        ],
      ),
      child: CustomPaint(
        foregroundPainter: const _ScratchPainter(),
        child: Container(
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
          decoration: BoxDecoration(
            color: _screen,
            borderRadius: BorderRadius.circular(screenRadius),
            border: Border.all(color: _frameEdge, width: 2),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  title.toUpperCase(),
                  maxLines: 1,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: ink,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              // [corner] sits in the empty space under [leading], so it adds
              // no height to the label.
              Stack(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // At most two short lines; the price shrinks to fit
                      // instead.
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 112),
                        child: Text(leading, style: small),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Semantics(
                            label: Money.format(cents),
                            excludeSemantics: true,
                            child: _Price(
                              euros: euros,
                              cents: (cents.abs() % 100).toString().padLeft(
                                2,
                                '0',
                              ),
                              style: theme.textTheme.displayLarge?.copyWith(
                                color: ink,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ExcludeSemantics(
                        child: CustomPaint(
                          size: const Size.square(52),
                          painter: _QrPainter(_qr),
                        ),
                      ),
                    ],
                  ),
                  if (corner != null)
                    Positioned(left: 0, bottom: 0, child: corner),
                ],
              ),
              const SizedBox(height: 6),
              Text(footer, style: small),
            ],
          ),
        ),
      ),
    );
    if (!plastic) return label;
    return PlasticPlate(
      params: plasticParams,
      // frameRadius and screenRadius are the plate's defaults.
      screenInsets: screenInsets,
      child: label,
    );
  }
}

/// Shelf-label price: big euros, then the cents raised and "€" below them.
class _Price extends StatelessWidget {
  const new({required this.euros, required this.cents, required this.style});

  final String euros;
  final String cents;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final big = style?.copyWith(fontSize: 96, height: 0.85);
    final side = style?.copyWith(fontSize: 38, height: 0.9);
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(euros, style: big),
        const SizedBox(width: 2),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(cents, style: side),
            const SizedBox(height: 10),
            Text('€', style: side?.copyWith(fontSize: 30)),
          ],
        ),
      ],
    );
  }
}

/// Draws [image]'s dark modules in the label's ink, filling the square.
class _QrPainter extends CustomPainter {
  const new(this.image);

  final QrImage image;

  @override
  void paint(Canvas canvas, Size size) {
    final count = image.moduleCount;
    final cell = size.width / count;
    final paint = Paint()
      ..color = ShelfLabel.ink
      ..isAntiAlias = false;
    for (var row = 0; row < count; row++) {
      for (var col = 0; col < count; col++) {
        if (!image.isDark(row, col)) continue;
        // A hair wider than the cell, so neighbours leave no seams.
        canvas.drawRect(
          Rect.fromLTWH(col * cell, row * cell, cell + 0.5, cell + 0.5),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(_QrPainter oldDelegate) => oldDelegate.image != image;
}

/// One scratch: a run of points, drawn as short segments so it can break up.
class _Scratch {
  const new(this.points, this.width, this.alpha);

  final List<Offset> points;
  final double width;
  final double alpha;
}

/// Wear on the label's plastic cover, over the ink: a few long hairline
/// scratches with gaps, tufts of short parallel ones, and fine specks, in
/// translucent white. Laid out once in logical pixels on a sheet larger
/// than any label and clipped, so the marks keep their size on any screen.
/// Seeded, so the label wears the same way on every launch.
class _ScratchPainter extends CustomPainter {
  const new();

  static const _sheet = Size(440, 240);
  static final (List<_Scratch>, List<_Scratch>) _wear = _layOut(Random(11));

  static (List<_Scratch>, List<_Scratch>) _layOut(Random random) {
    double between(double a, double b) => a + random.nextDouble() * (b - a);
    Offset anywhere() =>
        Offset(between(-20, _sheet.width), between(-20, _sheet.height));

    // A gently bent line from [start], [length] long, sampled every 3 px.
    List<Offset> line(Offset start, double angle, double length, double bend) {
      final steps = max(2, length ~/ 3);
      return [
        for (var i = 0; i <= steps; i++)
          () {
            final t = i / steps;
            final a = angle + bend * (t - 0.5);
            final d = length * t;
            return start + Offset(cos(a) * d, sin(a) * d);
          }(),
      ];
    }

    final scratches = <_Scratch>[
      // Long hairlines across the screen.
      for (var i = 0; i < 6; i++)
        _Scratch(
          line(
            anywhere(),
            between(0, pi),
            between(120, 360),
            between(-0.3, 0.3),
          ),
          between(0.6, 1.4),
          between(0.35, 0.6),
        ),
    ];
    // Tufts: short scratches side by side, as from one scrape.
    for (var i = 0; i < 4; i++) {
      final centre = anywhere();
      final angle = between(0, pi);
      final across = Offset(-sin(angle), cos(angle));
      final count = 4 + random.nextInt(5);
      for (var j = 0; j < count; j++) {
        final length = between(14, 48);
        final start =
            centre +
            across * between(-7, 7) +
            Offset(cos(angle), sin(angle)) * between(-12, 12);
        scratches.add(
          _Scratch(
            line(start, angle + between(-0.12, 0.12), length, 0),
            between(0.5, 1),
            between(0.3, 0.55),
          ),
        );
      }
    }

    final specks = <_Scratch>[
      for (var i = 0; i < 160; i++)
        _Scratch(
          [Offset(between(0, _sheet.width), between(0, _sheet.height))],
          between(0.4, 1.1),
          between(0.3, 0.6),
        ),
    ];
    return (scratches, specks);
  }

  @override
  void paint(Canvas canvas, Size size) {
    canvas
      ..save()
      ..clipRect(Offset.zero & size);
    final random = Random(5);
    final paint = Paint()..strokeCap = StrokeCap.round;
    final (scratches, specks) = _wear;
    for (final scratch in scratches) {
      final points = scratch.points;
      for (var i = 1; i < points.length; i++) {
        // Some segments skip, so the scratch looks broken, not ruled.
        if (random.nextDouble() < 0.18) continue;
        // Thinner towards the ends.
        final t = i / points.length;
        paint
          ..strokeWidth = scratch.width * (0.4 + 0.6 * sin(pi * t))
          ..color = Colors.white.withValues(alpha: scratch.alpha);
        canvas.drawLine(points[i - 1], points[i], paint);
      }
    }
    paint.style = PaintingStyle.fill;
    for (final speck in specks) {
      paint.color = Colors.white.withValues(alpha: speck.alpha);
      canvas.drawCircle(speck.points.single, speck.width, paint);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_ScratchPainter oldDelegate) => false;
}
