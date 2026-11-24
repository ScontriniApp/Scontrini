/// The key that makes two printed names the same product: upper case,
/// without accents and punctuation, single spaces. `Latte intero`,
/// `LATTE INTERO` and `LATTE  INTERO.` share `LATTE INTERO`.
///
/// Stored in `product_aliases.raw_name`. Exact keys only for now: OCR
/// variants (`MOZZARELA`) are separate products until a similarity match
/// or a manual merge joins them.
String productKey(String rawName) {
  final buffer = StringBuffer();
  for (final rune in rawName.toUpperCase().runes) {
    final char = String.fromCharCode(rune);
    buffer.write(_accents[char] ?? char);
  }
  return buffer.toString().replaceAll(RegExp('[^A-Z0-9]+'), ' ').trim();
}

const _accents = {
  'À': 'A', 'Á': 'A', 'Â': 'A', 'Ä': 'A', 'Ã': 'A', //
  'È': 'E', 'É': 'E', 'Ê': 'E', 'Ë': 'E', //
  'Ì': 'I', 'Í': 'I', 'Î': 'I', 'Ï': 'I', //
  'Ò': 'O', 'Ó': 'O', 'Ô': 'O', 'Ö': 'O', 'Õ': 'O', //
  'Ù': 'U', 'Ú': 'U', 'Û': 'U', 'Ü': 'U', //
  'Ç': 'C', 'Ñ': 'N',
};
