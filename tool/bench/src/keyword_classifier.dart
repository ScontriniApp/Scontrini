import 'package:scontrini/core/database/category_classifier.dart';
import 'package:scontrini/core/database/default_categories.dart';

/// Step 3: the app's own classifier (`CategoryClassifier`) with the seed
/// keywords in `default_categories.dart`. Returns `null` when nothing
/// matches. Any future classifier should beat this to be worth shipping.
String? keywordCategory(String rawName) => _classifier.classify(rawName);

final _classifier = CategoryClassifier<String>({
  for (final category in defaultCategories)
    for (final keyword in category.keywords) keyword: category.name,
});
