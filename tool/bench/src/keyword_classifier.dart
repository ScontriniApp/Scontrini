import 'package:scontrini/core/database/default_categories.dart';

/// Baseline for step 3: the seed keywords in `default_categories.dart`, with
/// a keyword matching at the start of a word. Returns `null` when nothing
/// matches. Any future classifier should beat this to be worth shipping.
String? keywordCategory(String rawName) {
  final name = rawName.toUpperCase();
  for (final category in defaultCategories) {
    for (final keyword in category.keywords) {
      if (_wordStart(keyword).hasMatch(name)) return category.name;
    }
  }
  return null;
}

final _patterns = <String, RegExp>{};

RegExp _wordStart(String keyword) =>
    _patterns[keyword] ??= RegExp('(^|[^A-Z])${RegExp.escape(keyword)}');
