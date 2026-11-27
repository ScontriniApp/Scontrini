import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:scontrini/app/theme.dart';
import 'package:scontrini/core/paper/paper_params.dart';
import 'package:scontrini/core/recess/recess_params.dart';
import 'package:scontrini/core/recess/recess_settings.dart';
import 'package:scontrini/core/recess/recessed_panel.dart';
import 'package:scontrini/core/utils/settings_store.dart';
import 'package:scontrini/features/pantry/presentation/pantry_colors.dart';

void main() {
  test('JSON round trip; missing or bad knobs keep their defaults', () {
    const tuned = RecessParams(depth: 31, eyeY: 0.2, lift: 9.5);
    expect(RecessParams.fromJson(tuned.toJson()), tuned);
    final partial = RecessParams.fromJson(const {'depth': 40, 'radius': 'x'});
    expect(partial.depth, 40);
    expect(partial.radius, const RecessParams().radius);
    expect(tuned.toJson().containsKey('debugView'), isFalse);
    expect(tuned.toDart(), startsWith('RecessParams(depth: 31.00,'));
  });

  test('the pantry colours round trip; no text or icon colour = theme', () {
    const tuned = RecessParams(
      accent: Color(0xFF1B5E20),
      titleColor: Color(0xFFB71C1C),
      textColor: Color(0xFF424242),
      iconColor: Color(0xFF0D47A1),
    );
    expect(RecessParams.fromJson(tuned.toJson()), tuned);
    expect(tuned.toDart(), contains('iconColor: Color(0xff0d47a1)'));
    final cleared = tuned.copyWith(textColor: null);
    expect(cleared.textColor, isNull);
    expect(cleared.iconColor, const Color(0xFF0D47A1));
    expect(const RecessParams().toJson().containsKey('textColor'), isFalse);
    expect(const RecessParams().accent, const Color(0xFFC58003));
  });

  test('the pantry takes its colours from the lab, not the app accent', () {
    final app = AppTheme.withAccent(AppTheme.light, const Color(0xFF1A237E));
    final pantry = PantryColors.themed(
      app,
      const RecessParams(
        accent: Color(0xFF1B5E20),
        textColor: Color(0xFF424242),
        iconColor: Color(0xFF0D47A1),
      ),
    );
    expect(pantry.colorScheme.primary, const Color(0xFF1B5E20));
    expect(pantry.textTheme.titleMedium!.color, const Color(0xFF424242));
    expect(pantry.iconTheme.color, const Color(0xFF0D47A1));
    expect(
      PantryColors.themed(app, const RecessParams()).colorScheme.primary,
      const Color(0xFFC58003),
    );
  });

  test('the file store reads back what was saved', () async {
    final dir = await Directory.systemTemp.createTemp('recess');
    addTearDown(() => dir.delete(recursive: true));
    final file = File('${dir.path}/recess_settings.json');
    final store = await openRecessSettingsFile(file: file);
    expect(store.initial, const RecessParams());
    store.save(const RecessParams(depth: 12));
    await store.flush();
    final again = await openRecessSettingsFile(file: file);
    expect(again.initial.depth, 12);
  });

  test('the provider saves without the debug view', () {
    final store = MemorySettingsStore(const RecessParams());
    final container = ProviderContainer(
      overrides: [recessSettingsStoreProvider.overrideWithValue(store)],
    );
    addTearDown(container.dispose);
    container
        .read(recessSettingsProvider.notifier)
        .set(const RecessParams(depth: 30, debugView: RecessDebugView.normals));
    expect(container.read(recessSettingsProvider).depth, 30);
    expect(store.saved.debugView, RecessDebugView.result);
    container.read(recessSettingsProvider.notifier).reset();
    expect(store.saved, const RecessParams());
  });

  test('content shadows fall away from the lamp, longer when lifted', () {
    // Lamp up and to the left: the shadow goes down and to the right.
    final light = const PaperLight(azimuth: 2.4).direction;
    final low = RecessedPanel.contentShadows(
      light,
      const RecessParams(lift: 4),
    ).single;
    final high = RecessedPanel.contentShadows(
      light,
      const RecessParams(lift: 12),
    ).single;
    expect(low.offset.dx, greaterThan(0));
    expect(low.offset.dy, greaterThan(0));
    expect(high.offset.distance, greaterThan(low.offset.distance));
    expect(
      RecessedPanel.contentShadows(light, const RecessParams(textShadow: 0)),
      isEmpty,
    );
  });
}
