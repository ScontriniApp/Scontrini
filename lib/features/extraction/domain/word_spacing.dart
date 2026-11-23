/// One recognised character and its horizontal extent.
class OcrGlyph {
  const new(this.text, this.left, this.right);

  final String text;
  final double left;
  final double right;

  double get center => (left + right) / 2;
}

/// Rebuilds the spaces in a line of receipt text from character positions.
///
/// Receipt printers use fixed-width fonts: a narrow letter such as `I` or `l`
/// sits in the middle of a full-width cell, and ML Kit takes the blank around
/// it for a word break (`CODI CE`, `I VA`, `el ettroni co`). Gaps between
/// glyphs are therefore misleading, but the distance between glyph centres
/// is not: one cell (the pitch) for neighbouring letters, two or more across
/// a real space. Words whose facing glyphs are less than [spaceRatio]
/// pitches apart are joined.
class WordSpacing {
  const new({this.spaceRatio = 1.4, this.minSamples = 3});

  /// Centre distance, in pitches, from which a gap counts as a real space.
  /// Fixed-width text gives 1 (same word) or 2+ (space); proportional fonts
  /// give about 1.5 across a space, so this stays below that.
  final double spaceRatio;

  /// Glyph pairs needed to trust a pitch measured on a single line.
  final int minSamples;

  /// Median centre distance between neighbouring glyphs inside words, over
  /// all [lines] of a page. `null` when there is not enough text.
  double? pagePitch(Iterable<List<List<OcrGlyph>>> lines) =>
      _median([for (final words in lines) ..._samples(words)]);

  /// The line's text with spaces only where the geometry shows one. Uses the
  /// line's own pitch when it has enough glyphs (big fonts like TOTALE have a
  /// larger pitch), else [pagePitch]. Returns `null` when no pitch is known,
  /// so the caller keeps the recogniser's text.
  String? join(List<List<OcrGlyph>> words, {double? pagePitch}) {
    final nonEmpty = [
      for (final word in words)
        if (word.isNotEmpty)
          [...word]..sort((a, b) => a.left.compareTo(b.left)),
    ]..sort((a, b) => a.first.left.compareTo(b.first.left));
    if (nonEmpty.isEmpty) return null;

    final samples = _samples(nonEmpty);
    final pitch = samples.length >= minSamples ? _median(samples) : pagePitch;
    if (pitch == null || pitch <= 0) return null;

    final buffer = StringBuffer();
    for (final (i, word) in nonEmpty.indexed) {
      if (i > 0) {
        final distance = word.first.center - nonEmpty[i - 1].last.center;
        if (distance >= spaceRatio * pitch) buffer.write(' ');
      }
      for (final glyph in word) {
        buffer.write(glyph.text);
      }
    }
    return buffer.toString();
  }

  static List<double> _samples(List<List<OcrGlyph>> words) => [
    for (final word in words)
      for (var i = 1; i < word.length; i++)
        if (word[i].center > word[i - 1].center)
          word[i].center - word[i - 1].center,
  ];

  static double? _median(List<double> values) {
    if (values.isEmpty) return null;
    final sorted = [...values]..sort();
    final middle = sorted.length ~/ 2;
    return sorted.length.isOdd
        ? sorted[middle]
        : (sorted[middle - 1] + sorted[middle]) / 2;
  }
}
