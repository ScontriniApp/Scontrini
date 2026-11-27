import 'package:material_ui/material_ui.dart';
import 'package:scontrini/core/section_colors/section_surface.dart';
import 'package:scontrini/features/pantry/presentation/widgets/lot_avatar.dart';

/// A category's heading in a collapsible list (pantry, receipt detail):
/// sprite, name, a short [trailing] figure and a chevron. A tap opens or
/// closes the section; [onTap] null means it can't be closed (searching).
class CategorySectionHeader extends StatelessWidget {
  const new({
    required this.title,
    required this.trailing,
    required this.open,
    required this.onTap,
    this.sprite,
    this.titleColor,
    super.key,
  });

  final String title;

  /// Asset of the category's sprite, if it has one.
  final String? sprite;

  /// E.g. how many lots, or what the section cost.
  final String trailing;
  final bool open;
  final VoidCallback? onTap;

  /// Overrides the heading colour ([SectionSurface.headingColor]).
  final Color? titleColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
        child: Row(
          spacing: 12,
          children: [
            if (sprite case final sprite?)
              CategorySpriteImage(sprite, size: 40),
            Expanded(
              child: Text(
                title,
                style: theme.textTheme.titleLarge?.copyWith(
                  color: titleColor ?? SectionSurface.headingColor(context),
                ),
              ),
            ),
            Text(trailing, style: theme.textTheme.titleMedium),
            Icon(open ? Icons.expand_less : Icons.expand_more),
          ],
        ),
      ),
    );
  }
}
