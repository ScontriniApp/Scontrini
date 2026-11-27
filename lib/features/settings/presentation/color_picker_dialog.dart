import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:scontrini/l10n/app_localizations.dart';

/// Asks for any colour: saturation × brightness square, hue bar, hex code
/// and a few shortcuts. Returns the colour, or `null` when cancelled.
Future<Color?> showColorPicker(
  BuildContext context, {
  required String title,
  required Color initial,
  List<Color> shortcuts = const [],
}) => showDialog<Color>(
  context: context,
  builder: (context) =>
      ColorPickerDialog(title: title, initial: initial, shortcuts: shortcuts),
);

/// `#RRGGBB`, upper case.
String colorHex(Color c) =>
    '#${(c.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0')}'
        .toUpperCase();

/// The colour of `RRGGBB` / `#RRGGBB`, or `null`.
Color? parseColorHex(String text) {
  final digits = text.trim().replaceFirst('#', '');
  if (!RegExp(r'^[0-9a-fA-F]{6}$').hasMatch(digits)) return null;
  return Color(0xFF000000 | int.parse(digits, radix: 16));
}

/// Width of the dialog's content; the square and hue bar fill it.
const double _pickerWidth = 280;

class ColorPickerDialog extends StatefulWidget {
  const new({
    required this.title,
    required this.initial,
    this.shortcuts = const [],
    super.key,
  });

  final String title;
  final Color initial;
  final List<Color> shortcuts;

  @override
  State<ColorPickerDialog> createState() => _ColorPickerDialogState();
}

class _ColorPickerDialogState extends State<ColorPickerDialog> {
  late HSVColor _hsv = HSVColor.fromColor(widget.initial.withAlpha(0xFF));
  late final _hex = TextEditingController(text: _hexDigits(widget.initial));

  @override
  void dispose() {
    _hex.dispose();
    super.dispose();
  }

  Color get _color => _hsv.toColor();

  static String _hexDigits(Color c) => colorHex(c).substring(1);

  /// From the square, bar or shortcuts: the hex field follows.
  void _set(HSVColor hsv) => setState(() {
    _hsv = hsv;
    _hex.text = _hexDigits(hsv.toColor());
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    return AlertDialog(
      title: Text(widget.title),
      scrollable: true,
      content: SizedBox(
        width: _pickerWidth,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 16,
          children: [
            _SaturationValueSquare(hsv: _hsv, onChanged: _set),
            _HueBar(hsv: _hsv, onChanged: _set),
            Row(
              spacing: 12,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _color,
                    shape: BoxShape.circle,
                    border: Border.all(color: scheme.outline),
                  ),
                ),
                Expanded(
                  child: TextField(
                    key: const Key('colorPickerHex'),
                    controller: _hex,
                    decoration: InputDecoration(
                      labelText: l10n.settingsColorHex,
                      prefixText: '#',
                      isDense: true,
                    ),
                    maxLength: 6,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp('[0-9a-fA-F]')),
                    ],
                    // Typed codes move the picker only once complete.
                    onChanged: (text) {
                      final color = parseColorHex(text);
                      if (color != null) {
                        setState(() => _hsv = HSVColor.fromColor(color));
                      }
                    },
                  ),
                ),
              ],
            ),
            if (widget.shortcuts.isNotEmpty)
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final c in widget.shortcuts)
                    Semantics(
                      label: colorHex(c),
                      button: true,
                      child: InkResponse(
                        onTap: () => _set(HSVColor.fromColor(c)),
                        radius: 18,
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: c,
                            shape: BoxShape.circle,
                            border: Border.all(color: scheme.outline),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(_color),
          child: Text(l10n.settingsColorApply),
        ),
      ],
    );
  }
}

/// Saturation left → right, brightness bottom → top, for the current hue.
class _SaturationValueSquare extends StatelessWidget {
  const new({required this.hsv, required this.onChanged});

  static const size = Size(_pickerWidth, 200);

  final HSVColor hsv;
  final ValueChanged<HSVColor> onChanged;

  void _pick(Offset p) => onChanged(
    hsv
        .withSaturation((p.dx / size.width).clamp(0, 1))
        .withValue(1 - (p.dy / size.height).clamp(0, 1)),
  );

  @override
  Widget build(BuildContext context) => Semantics(
    label: AppLocalizations.of(context).settingsColorSquare,
    child: GestureDetector(
      key: const Key('colorPickerSquare'),
      onPanDown: (d) => _pick(d.localPosition),
      onPanUpdate: (d) => _pick(d.localPosition),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: CustomPaint(painter: _SquarePainter(hsv), size: size),
      ),
    ),
  );
}

class _SquarePainter extends CustomPainter {
  new(this.hsv);

  final HSVColor hsv;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final pure = HSVColor.fromAHSV(1, hsv.hue, 1, 1).toColor();
    canvas
      ..drawRect(
        rect,
        Paint()
          ..shader = LinearGradient(colors: [const Color(0xFFFFFFFF), pure])
              .createShader(rect),
      )
      ..drawRect(
        rect,
        Paint()
          ..shader = const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0x00000000), Color(0xFF000000)],
          ).createShader(rect),
      );
    _thumb(
      canvas,
      Offset(hsv.saturation * size.width, (1 - hsv.value) * size.height),
    );
  }

  @override
  bool shouldRepaint(_SquarePainter old) => old.hsv != hsv;
}

/// The hues of the rainbow, left to right.
class _HueBar extends StatelessWidget {
  const new({required this.hsv, required this.onChanged});

  static const size = Size(_pickerWidth, 28);

  final HSVColor hsv;
  final ValueChanged<HSVColor> onChanged;

  void _pick(Offset p) =>
      onChanged(hsv.withHue((p.dx / size.width).clamp(0, 1) * 360));

  @override
  Widget build(BuildContext context) => Semantics(
    label: AppLocalizations.of(context).settingsColorHue,
    child: GestureDetector(
      key: const Key('colorPickerHue'),
      onPanDown: (d) => _pick(d.localPosition),
      onPanUpdate: (d) => _pick(d.localPosition),
      child: CustomPaint(painter: _HuePainter(hsv.hue), size: size),
    ),
  );
}

class _HuePainter extends CustomPainter {
  new(this.hue);

  final double hue;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(8)),
      Paint()
        ..shader = LinearGradient(
          colors: [
            for (var h = 0; h <= 360; h += 60)
              HSVColor.fromAHSV(1, h.toDouble(), 1, 1).toColor(),
          ],
        ).createShader(rect),
    );
    _thumb(canvas, Offset(hue / 360 * size.width, size.height / 2));
  }

  @override
  bool shouldRepaint(_HuePainter old) => old.hue != hue;
}

/// White ring with a dark edge: visible on any colour.
void _thumb(Canvas canvas, Offset at) => canvas
  ..drawCircle(
    at,
    9,
    Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..color = const Color(0x99000000),
  )
  ..drawCircle(
    at,
    9,
    Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = const Color(0xFFFFFFFF),
  );
