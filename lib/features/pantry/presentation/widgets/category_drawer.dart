import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:scontrini/core/recess/recess_params.dart';
import 'package:scontrini/core/recess/recess_settings.dart';
import 'package:scontrini/core/recess/recessed_panel.dart';
import 'package:scontrini/features/pantry/presentation/widgets/category_section_header.dart';

/// A pantry category as a drawer carved into the background
/// ([RecessedPanel]): closed, a shallow tray holding the category's
/// heading; tapped, it grows and deepens, and its lots float on the floor.
class CategoryDrawer extends ConsumerWidget {
  const new({
    required this.title,
    required this.trailing,
    required this.open,
    required this.onTap,
    required this.children,
    this.sprite,
    this.params,
    super.key,
  });

  final String title;
  final String trailing;
  final String? sprite;
  final bool open;

  /// Null: it can't be closed (searching).
  final VoidCallback? onTap;

  /// What an open drawer holds (one tile per lot).
  final List<Widget> children;

  /// Overrides [recessSettingsProvider] (the lab's debug view).
  final RecessParams? params;

  static const _duration = Duration(milliseconds: 260);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final watched = ref.watch(recessSettingsProvider);
    final p = params ?? watched;
    return TweenAnimationBuilder<double>(
      tween: Tween(end: open ? p.depth : p.closedDepth),
      duration: _duration,
      curve: Curves.easeOutCubic,
      builder: (context, depth, child) =>
          RecessedPanel(depth: depth, params: params, child: child!),
      child: AnimatedSize(
        duration: _duration,
        curve: Curves.easeOutCubic,
        alignment: Alignment.topCenter,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CategorySectionHeader(
              title: title,
              sprite: sprite,
              trailing: trailing,
              open: open,
              onTap: onTap,
              titleColor: p.titleColor,
            ),
            if (open) ...[...children, const SizedBox(height: 8)],
          ],
        ),
      ),
    );
  }
}
