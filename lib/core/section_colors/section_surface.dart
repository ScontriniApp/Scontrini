import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:scontrini/core/section_colors/section_colors_provider.dart';

/// Gives a plain section (a card, a history month, a pantry category) the
/// colours chosen in Settings. Not for paper or shelf labels, which keep
/// their own look.
///
/// It overrides the theme around [child], so the section's widgets must
/// read `Theme.of` below it: wrap the card widget, not the `Card` inside it.
/// Cards take the background; with [panel] (sections that are not cards)
/// a rounded panel is drawn behind [child] instead. Without a chosen text
/// colour, a background gets black or white text, whichever reads.
class SectionSurface extends ConsumerWidget {
  const new({required this.child, this.panel = false, super.key});

  final Widget child;
  final bool panel;

  /// Colour for headings that otherwise use the theme's primary colour.
  static Color headingColor(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_SectionText>()?.color ??
      Theme.of(context).colorScheme.primary;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = ref.watch(sectionColorsProvider);
    if (colors.sectionsDefault) return child;
    final base = Theme.of(context);
    final background = colors.background;
    final text = colors.text ?? _readableOn(background);

    var data = base;
    if (background != null) {
      data = data.copyWith(
        cardTheme: base.cardTheme.copyWith(color: background),
        colorScheme: data.colorScheme.copyWith(surfaceContainerLow: background),
      );
    }
    if (text != null) {
      final muted = text.withValues(alpha: 0.72);
      data = data.copyWith(
        colorScheme: data.colorScheme.copyWith(
          onSurface: text,
          onSurfaceVariant: muted,
        ),
        textTheme: data.textTheme.apply(bodyColor: text, displayColor: text),
        iconTheme: data.iconTheme.copyWith(color: muted),
      );
    }

    Widget result = _SectionText(
      color: text,
      child: Theme(data: data, child: child),
    );
    if (panel && background != null) {
      result = Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: Material(
          color: background,
          borderRadius: BorderRadius.circular(12),
          clipBehavior: Clip.antiAlias,
          child: result,
        ),
      );
    }
    return result;
  }

  static Color? _readableOn(Color? background) => switch (background) {
    null => null,
    final b =>
      ThemeData.estimateBrightnessForColor(b) == Brightness.dark
          ? const Color(0xFFFFFFFF)
          : const Color(0xFF000000),
  };
}

class _SectionText extends InheritedWidget {
  const new({required this.color, required super.child});

  final Color? color;

  @override
  bool updateShouldNotify(_SectionText old) => old.color != color;
}
