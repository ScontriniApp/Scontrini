import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scontrini/core/section_colors/section_colors.dart';
import 'package:scontrini/core/section_colors/section_colors_store.dart';

/// Where the section colours are saved. In memory unless overridden (`main`
/// passes the device's shared preferences).
final sectionColorsStoreProvider = Provider<SectionColorsStore>(
  (ref) => MemorySectionColorsStore(),
);

/// The background and text colour of the plain sections.
final sectionColorsProvider =
    NotifierProvider<SectionColorsNotifier, SectionColors>(
      SectionColorsNotifier.new,
    );

class SectionColorsNotifier extends Notifier<SectionColors> {
  @override
  SectionColors build() => ref.watch(sectionColorsStoreProvider).read();

  /// Applies [colors] and saves them.
  Future<void> select(SectionColors colors) async {
    if (colors == state) return;
    state = colors;
    await ref.read(sectionColorsStoreProvider).write(colors);
  }
}
