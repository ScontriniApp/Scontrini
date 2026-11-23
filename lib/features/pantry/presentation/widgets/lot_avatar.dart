import 'package:material_ui/material_ui.dart';

/// Placeholder for the product's 8-bit sprite: a square tile in the
/// category colour with the product's initials.
class LotAvatar extends StatelessWidget {
  const new({required this.name, required this.color, super.key});

  final String name;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final words = name.trim().split(RegExp(r'\s+'));
    final initials = words
        .where((w) => w.isNotEmpty)
        .take(2)
        .map((w) => w[0].toUpperCase())
        .join();
    final onColor = color.computeLuminance() > 0.5
        ? Colors.black87
        : Colors.white;
    return Container(
      width: 40,
      height: 40,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        initials,
        style: TextStyle(
          color: onColor,
          fontWeight: FontWeight.bold,
          fontFamily: 'monospace',
        ),
      ),
    );
  }
}
