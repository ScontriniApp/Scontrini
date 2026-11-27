import 'package:flutter_test/flutter_test.dart';
import 'package:scontrini/features/receipts/presentation/receipt_detail_screen.dart';

void main() {
  test('receipt detail paper keeps the tuned look', () {
    expect(
      receiptDetailPaper.toDart(),
      'PaperParams(seed: 1.00, creases: 0.64, crumple: 1.77, '
      'sharpness: 0.26, depth: 0.75, lightDistance: 1500.00, '
      'cameraDistance: 1800.00, cameraTilt: 0.30, cameraTurn: 1.77, '
      'ambient: 0.73, occlusion: 1.07, shadow: 0.80, softness: 0.53, '
      'sheen: 0.00, roughness: 0.13, fibres: 1.00, edge: 0.45, '
      'levels: 0.00, pixel: 2.00, ink: PaperInk.thermal, inkFade: 0.37, '
      'lines: 0.44, dropout: 0.19, torn: 8.57, corner: 0.00)',
    );
  });
}
