import 'package:material_ui/material_ui.dart';

/// Makes a non-scrolling [child] (an empty state) fill the space and still
/// scroll, so a surrounding `RefreshIndicator` can be pulled on it.
class RefreshableFill extends StatelessWidget {
  const new({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) => SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: constraints.maxHeight),
        child: child,
      ),
    ),
  );
}
