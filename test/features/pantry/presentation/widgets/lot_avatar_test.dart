import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:scontrini/features/pantry/presentation/category_sprites.dart';
import 'package:scontrini/features/pantry/presentation/widgets/lot_avatar.dart';

Widget _app(Widget child) => MaterialApp(home: Center(child: child));

void main() {
  test('Pane e pasta has a sprite, other categories none yet', () {
    expect(categorySprite('Pane e pasta'), isNotNull);
    expect(categorySprite('Bevande'), isNull);
    expect(categorySprite(null), isNull);
  });

  testWidgets('without a sprite the tile shows the initials', (tester) async {
    await tester.pumpWidget(
      _app(const LotAvatar(name: 'latte intero', color: Colors.blue)),
    );
    expect(find.text('LI'), findsOneWidget);
    expect(find.byType(Image), findsNothing);
  });

  testWidgets('a sprite is drawn with sharp pixels instead', (tester) async {
    await tester.pumpWidget(
      _app(
        LotAvatar(
          name: 'PANE',
          color: Colors.orange,
          sprite: categorySprite('Pane e pasta'),
        ),
      ),
    );
    final image = tester.widget<Image>(find.byType(Image));
    expect(image.filterQuality, FilterQuality.none);
    // Scaled up to the tile, not left at its 16 px.
    expect(image.fit, BoxFit.contain);
    expect(tester.getSize(find.byType(Image)), const Size(36, 36));
    expect(find.text('PA'), findsNothing);
  });
}
