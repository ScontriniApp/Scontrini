// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Receipts';

  @override
  String get navHome => 'Home';

  @override
  String get navReceipts => 'History';

  @override
  String get navAnalytics => 'Analytics';

  @override
  String get navInsights => 'Tips';

  @override
  String get addReceipt => 'Add';

  @override
  String get settings => 'Settings';

  @override
  String get captureTitle => 'New receipt';

  @override
  String get captureScan => 'Scan with camera';

  @override
  String get captureGallery => 'Choose from gallery';

  @override
  String get capturePdf => 'Import PDF';

  @override
  String get comingSoon => 'Coming soon';

  @override
  String get dashboardEmpty =>
      'No receipts yet.\nAdd your first one to see your spending.';

  @override
  String get receiptsEmpty => 'Your purchase history will appear here.';

  @override
  String get analyticsEmpty => 'Charts and statistics will appear here.';

  @override
  String get insightsEmpty => 'Personalised tips will appear here.';

  @override
  String get settingsEmpty => 'Categories, backup and security.';

  @override
  String get demoDataTitle => 'Demo data (debug only)';

  @override
  String get demoDataLoad => 'Load demo data';

  @override
  String get demoDataLoadHint =>
      '6 months of made-up purchases. They add up with real receipts until you remove them.';

  @override
  String get demoDataRemove => 'Remove demo data';

  @override
  String demoDataLoaded(int count) {
    return 'Loaded $count demo receipts';
  }

  @override
  String get demoDataRemoved => 'Demo data removed';

  @override
  String dashboardMonthSpent(String month) {
    return 'Spent in $month';
  }

  @override
  String dashboardReceiptCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count receipts',
      one: '1 receipt',
      zero: 'No receipts',
    );
    return '$_temp0';
  }

  @override
  String dashboardUsual(String amount) {
    return 'Usually $amount by this point of the month';
  }

  @override
  String get dashboardNoUsual =>
      'The comparison with past months will appear next month';

  @override
  String get dashboardCategoriesTitle => 'Categories this month';

  @override
  String get dashboardCategoriesEmpty => 'No spending this month';

  @override
  String get dashboardOtherCategories => 'Other categories';

  @override
  String get dashboardInsightsTitle => 'Suggestions';

  @override
  String get dashboardInsightsEmpty =>
      '2–3 suggestions about your shopping will appear here: rising prices, ways to save, growing categories.';

  @override
  String get dashboardCategoryHint => 'Tap a category to see its items';

  @override
  String dashboardItemCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items',
      one: '1 item',
      zero: 'No items',
    );
    return '$_temp0';
  }

  @override
  String dashboardUnassigned(String amount) {
    return '$amount not tied to an item (basket discounts, unread lines)';
  }

  @override
  String dashboardFullPrice(String amount) {
    return 'full price $amount';
  }
}
