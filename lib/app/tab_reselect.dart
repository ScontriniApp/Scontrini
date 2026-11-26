import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Positions of the bottom-bar tabs (the router's shell branches).
abstract final class ShellBranch {
  static const home = 0;
  static const receipts = 1;
  static const analytics = 2;
  static const pantry = 3;
}

/// A tap on the tab that is already open: screens listen for their branch
/// and refresh. `serial` makes two taps in a row two events.
typedef TabReselect = ({int branch, int serial});

final NotifierProvider<TabReselectNotifier, TabReselect?> tabReselectProvider =
    NotifierProvider(TabReselectNotifier.new);

class TabReselectNotifier extends Notifier<TabReselect?> {
  @override
  TabReselect? build() => null;

  void reselect(int branch) =>
      state = (branch: branch, serial: (state?.serial ?? 0) + 1);
}
