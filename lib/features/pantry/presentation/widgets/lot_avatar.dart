import 'package:material_ui/material_ui.dart';

/// A product's tile: its category's 8-bit [sprite] when there is one,
/// otherwise the product's initials, on the category colour.
class LotAvatar extends StatelessWidget {
  const new({required this.name, required this.color, this.sprite, super.key});

  final String name;
  final Color color;

  /// Asset path of a pixel-art sprite (see `category_sprites.dart`).
  final String? sprite;

  @override
  Widget build(BuildContext context) {
    final sprite = this.sprite;
    return Container(
      width: 40,
      height: 40,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        // A lighter tile behind a sprite, so its own colours stand out.
        color: sprite == null ? color : color.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(4),
      ),
      child: sprite == null
          ? _Initials(name: name, color: color)
          : CategorySpriteImage(sprite, size: 36),
    );
  }
}

/// A pixel-art sprite scaled up without smoothing, so pixels stay sharp.
class CategorySpriteImage extends StatelessWidget {
  const new(this.asset, {required this.size, super.key});

  final String asset;
  final double size;

  @override
  Widget build(BuildContext context) => Image.asset(
    asset,
    width: size,
    height: size,
    // Without a fit Flutter only scales images down: a 16 px sprite would
    // stay 16 px. Contain scales it up to the box, sharp.
    fit: BoxFit.contain,
    filterQuality: FilterQuality.none,
    // A missing asset must not break the list.
    errorBuilder: (_, _, _) => SizedBox.square(dimension: size),
  );
}

class _Initials extends StatelessWidget {
  const new({required this.name, required this.color});

  final String name;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final initials = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .take(2)
        .map((w) => w[0].toUpperCase())
        .join();
    final onColor = color.computeLuminance() > 0.5
        ? Colors.black87
        : Colors.white;
    return Text(
      initials,
      style: TextStyle(
        color: onColor,
        fontWeight: FontWeight.bold,
        fontFamily: 'monospace',
      ),
    );
  }
}
