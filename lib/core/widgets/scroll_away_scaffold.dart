import 'package:material_ui/material_ui.dart';

/// A tab's page whose app bar scrolls away with the content: scrolling down
/// slides it up at the same pace as the list, scrolling back up (anywhere in
/// the list) brings it down again at the same pace. No snapping.
///
/// The bar slides under the status bar's strip, which keeps the page's
/// background, so the content never shows behind the system icons.
///
/// [body] is laid out under the bar; its vertical list (any depth, e.g. in a
/// `TabBarView` or under a search field) must use the primary scroll
/// controller: no `controller` of its own.
class ScrollAwayScaffold extends StatelessWidget {
  const new({
    required this.title,
    required this.body,
    this.actions = const [],
    this.bottom,
    super.key,
  });

  final Widget title;
  final List<Widget> actions;

  /// Slides away with the bar (e.g. a `TabBar`).
  final PreferredSizeWidget? bottom;
  final Widget body;

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      bottom: false,
      child: NestedScrollView(
        // The bar comes back as soon as the list scrolls up, not only at its
        // top.
        floatHeaderSlivers: true,
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar(
            // The status bar's room is the SafeArea's, not the bar's.
            primary: false,
            floating: true,
            // Over the scrolled list too, the bar keeps the page's
            // background: no tint, no shadow.
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            surfaceTintColor: Colors.transparent,
            scrolledUnderElevation: 0,
            elevation: 0,
            title: title,
            actions: actions,
            bottom: bottom,
          ),
        ],
        body: body,
      ),
    ),
  );
}
