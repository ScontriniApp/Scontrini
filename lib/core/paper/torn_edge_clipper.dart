import 'package:material_ui/material_ui.dart';

/// Zigzag tear along the top and bottom, like a receipt torn off the roll.
class TornEdgeClipper extends CustomClipper<Path> {
  const new({this.tooth = 6});

  /// Width of one tooth; its height is half of it.
  final double tooth;

  @override
  Path getClip(Size size) {
    final depth = tooth / 2;
    final teeth = (size.width / tooth).ceil();
    final step = size.width / teeth;
    final path = Path()..moveTo(0, depth);
    for (var i = 0; i < teeth; i++) {
      path
        ..lineTo(step * (i + 0.5), 0)
        ..lineTo(step * (i + 1), depth);
    }
    path.lineTo(size.width, size.height - depth);
    for (var i = teeth; i > 0; i--) {
      path
        ..lineTo(step * (i - 0.5), size.height)
        ..lineTo(step * (i - 1), size.height - depth);
    }
    return path..close();
  }

  @override
  bool shouldReclip(TornEdgeClipper old) => old.tooth != tooth;
}
