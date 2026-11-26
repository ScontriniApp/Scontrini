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
  String get receiptsEmpty =>
      'No receipts yet. Take a photo of one or type it in by hand.';

  @override
  String get captureFailed => 'Couldn\'t capture the receipt.';

  @override
  String get extractionTitle => 'Receipt read';

  @override
  String get extractionLoading => 'Reading the receipt…';

  @override
  String get extractionFailed => 'Couldn\'t read the receipt.';

  @override
  String get retry => 'Retry';

  @override
  String get fieldStore => 'Store';

  @override
  String get fieldDate => 'Date';

  @override
  String get fieldTotal => 'Total';

  @override
  String get fieldItemsTotal => 'Items total';

  @override
  String extractionItems(int count) {
    return 'Items ($count)';
  }

  @override
  String extractionDiscount(String amount) {
    return 'Discount $amount';
  }

  @override
  String get extractionReceiptDiscount => 'Discounts on the total';

  @override
  String get extractionUnparsed => 'Unrecognised rows';

  @override
  String get extractionRawText => 'Recognised text';

  @override
  String get warningMissingStore => 'Store not found';

  @override
  String get warningMissingDate => 'Date not found';

  @override
  String get warningMissingTotal => 'Total not found';

  @override
  String get warningTotalMismatch => 'The items don\'t add up to the total';

  @override
  String get warningLineTotalMismatch =>
      'Quantity × price differs from the line amount';

  @override
  String get exportFixture => 'Export as test';

  @override
  String exportFixtureDone(String name) {
    return 'Saved: $name';
  }

  @override
  String get navPantry => 'Pantry';

  @override
  String get pantryEmpty =>
      'Your pantry is empty.\nAdd products from a receipt or by hand.';

  @override
  String get pantryShowClosed => 'Show finished and thrown away';

  @override
  String get pantryHideClosed => 'Hide finished and thrown away';

  @override
  String get pantryAdd => 'Add a receipt by hand';

  @override
  String get pantryUncategorised => 'Uncategorised';

  @override
  String pantryRemaining(String remaining, String initial) {
    return '$remaining of $initial';
  }

  @override
  String get pantrySourceManualPurchase => 'Bought, no receipt';

  @override
  String get pantrySourceInitialStock => 'Already at home';

  @override
  String get pantrySourceGift => 'Gift';

  @override
  String get pantryStatusConsumed => 'Finished';

  @override
  String get pantryStatusDiscarded => 'Thrown away';

  @override
  String get pantryConsumeAll => 'Mark as finished';

  @override
  String get pantryDiscard => 'Throw away';

  @override
  String get pantryReasonExpired => 'Expired';

  @override
  String get pantryReasonSpoiled => 'Spoiled';

  @override
  String get pantryReasonOther => 'Other reason';

  @override
  String get pantryUndo => 'Undo';

  @override
  String get pantryUndoLast => 'Undo last action';

  @override
  String get pantryNothingToUndo => 'Nothing to undo';

  @override
  String get pantryDelete => 'Remove from pantry';

  @override
  String pantryDeleteConfirm(String name) {
    return 'Remove $name? Its usage history will be lost.';
  }

  @override
  String pantryConsumedMessage(String name, String amount) {
    return '$name: used $amount';
  }

  @override
  String pantryDiscardedMessage(String name) {
    return '$name thrown away';
  }

  @override
  String pantryFinishedMessage(String name) {
    return '$name finished';
  }

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Remove';

  @override
  String get save => 'Save';

  @override
  String get unitPieces => 'pcs';

  @override
  String get unitKilograms => 'kg';

  @override
  String get unitLitres => 'l';

  @override
  String get extractionStepPreparing => 'Preparing the photo…';

  @override
  String get extractionStepFindingLines => 'Finding the lines…';

  @override
  String get extractionStepReadingLines => 'Reading the lines…';

  @override
  String get extractionStepParsing => 'Putting the receipt together…';

  @override
  String get confirmFailed => 'Could not save the receipt.';

  @override
  String get navInsights => 'Tips';

  @override
  String get insightsEmpty => 'Personalised tips will appear here.';

  @override
  String get settingsEmpty => 'Categories, backup and security.';

  @override
  String get shaderLabTitle => 'Paper lab';

  @override
  String get shaderLabHint => 'Tune the crumpled receipt look.';

  @override
  String get shaderLabInkUnsupported =>
      'Shader ink isn\'t available here (needs Impeller): the text is drawn on top of the paper.';

  @override
  String get shaderLabReceipt => 'Receipt';

  @override
  String get shaderLabComponents => 'Components';

  @override
  String get shaderLabInkOff => 'On top';

  @override
  String get shaderLabInkThermal => 'Thermal';

  @override
  String get shaderLabInkColour => 'Colour';

  @override
  String get shaderLabNewSeed => 'New creases';

  @override
  String get shaderLabReset => 'Reset';

  @override
  String get shaderLabCopy => 'Copy values';

  @override
  String get shaderLabCopied => 'Values copied to the clipboard';

  @override
  String get shaderLabHideControls => 'Show/hide the controls';

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
  String get dashboardRestSlice => 'Other and uncategorised';

  @override
  String get dashboardInsightsTitle => 'Suggestions';

  @override
  String get dashboardInsightsEmpty =>
      'No suggestions for now. Rising prices, categories where you spend more than usual and products you often throw away will appear here.';

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

  @override
  String get pantrySearchHint => 'Search the pantry';

  @override
  String get pantrySearchClear => 'Clear search';

  @override
  String get pantryNoResults => 'No products found.';

  @override
  String get captureManual => 'Type it in by hand';

  @override
  String get manualReceiptTitle => 'Receipt by hand';

  @override
  String get manualReceiptNotice =>
      'Add the products you bought. Saving adds the receipt to the history and its products to the pantry.';

  @override
  String get receiptsUnknownStore => 'Unknown store';

  @override
  String get receiptsManual => 'By hand';

  @override
  String receiptsItemCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items',
      one: '1 item',
    );
    return '$_temp0';
  }

  @override
  String get receiptDelete => 'Delete receipt';

  @override
  String get receiptDeleteConfirm =>
      'Delete the receipt? Its products leave the pantry too.';

  @override
  String get receiptDeleted => 'Receipt deleted';

  @override
  String get receiptNotFound => 'Receipt not found.';

  @override
  String get pantryManage => 'Manage in the pantry';

  @override
  String get pantryStatistics => 'View statistics';

  @override
  String get productStatsBought => 'Bought';

  @override
  String productStatsTimes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count times',
      one: 'once',
    );
    return '$_temp0';
  }

  @override
  String get productStatsLastPurchase => 'Last purchase';

  @override
  String get productStatsEvery => 'You buy it every';

  @override
  String productStatsDays(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days days or so',
      one: 'day or so',
    );
    return '$_temp0';
  }

  @override
  String get productStatsTotal => 'Spent in all';

  @override
  String get productStatsPrices => 'Prices paid';

  @override
  String get productStatsPricePerPiece => 'per piece';

  @override
  String get productStatsPricePerKg => 'per kg';

  @override
  String get productStatsPricePerLitre => 'per litre';

  @override
  String get productStatsOnePrice =>
      'The chart appears from the second purchase.';

  @override
  String get productStatsMin => 'Lowest';

  @override
  String get productStatsUsual => 'Usually';

  @override
  String get productStatsMax => 'Highest';

  @override
  String productStatsChangeUp(String percent) {
    return 'Last price $percent above usual';
  }

  @override
  String productStatsChangeDown(String percent) {
    return 'Last price $percent below usual';
  }

  @override
  String get productStatsChangeSame => 'Last price as usual';

  @override
  String get productStatsPurchases => 'Purchases';

  @override
  String get productStatsNoPurchases =>
      'No purchases recorded for this product.';

  @override
  String get productStatsPantry => 'In the pantry';

  @override
  String productStatsPantryNow(String quantity) {
    return 'You still have $quantity';
  }

  @override
  String get productStatsPantryNone => 'None in the pantry';

  @override
  String productStatsLotsEnded(int consumed, int discarded) {
    return 'Finished: $consumed · Thrown away: $discarded';
  }

  @override
  String get reviewTitle => 'Check the receipt';

  @override
  String get reviewNotice =>
      'Check each product: confirm it if it was read correctly, otherwise correct it. Saving adds the receipt to the dashboard and its products to the pantry.';

  @override
  String get reviewAddItem => 'Add item';

  @override
  String get reviewEditItem => 'Edit item';

  @override
  String get reviewFieldName => 'Name on the receipt';

  @override
  String get reviewFieldQuantity => 'Quantity';

  @override
  String get reviewFieldUnitPrice => 'Unit price';

  @override
  String get reviewFieldAmount => 'Amount';

  @override
  String get reviewFieldDiscount => 'Discount (optional)';

  @override
  String get reviewFieldCategory => 'Category';

  @override
  String get reviewInvalidName => 'Enter a name';

  @override
  String get reviewInvalidQuantity => 'Enter a quantity greater than zero';

  @override
  String get reviewInvalidAmount => 'Invalid amount';

  @override
  String get reviewDiscountTooLarge => 'The discount is more than the amount';

  @override
  String get reviewUncategorised => 'Uncategorised';

  @override
  String get reviewNoItems => 'No items: add at least one to confirm.';

  @override
  String get reviewUnparsedHint => 'If an item is missing, add it by hand.';

  @override
  String reviewItemDeleted(String name) {
    return '$name deleted';
  }

  @override
  String get reviewUndo => 'Undo';

  @override
  String get reviewDiscardTitle => 'Discard changes?';

  @override
  String get reviewDiscardBody => 'The receipt hasn\'t been saved yet.';

  @override
  String get reviewDiscard => 'Discard';

  @override
  String reviewMismatchDetail(String items, String total) {
    return 'Items sum $items, total $total';
  }

  @override
  String get reviewMissingDateHint => 'Without a date, today\'s is used.';

  @override
  String get reviewMissingTotalHint =>
      'Without a total, the items\' sum is used.';

  @override
  String get reviewUseItemsTotal => 'Use the sum';

  @override
  String get reviewSave => 'Save receipt';

  @override
  String reviewSaveBlocked(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count products left to check',
      one: '1 product left to check',
    );
    return '$_temp0';
  }

  @override
  String reviewItemsPending(int count, int pending) {
    return 'Items ($count), $pending to check';
  }

  @override
  String get reviewConfirmItem => 'Correct';

  @override
  String get reviewCorrectItem => 'Fix';

  @override
  String get reviewUnconfirmItem => 'Check again';

  @override
  String reviewSaved(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Receipt saved, $count products in the pantry.',
      one: 'Receipt saved, 1 product in the pantry.',
      zero: 'Receipt saved.',
    );
    return '$_temp0';
  }

  @override
  String reviewConfirmAll(int count) {
    return 'Confirm all ($count)';
  }

  @override
  String get analyticsTabSpending => 'Spending';

  @override
  String get analyticsTabProducts => 'Products';

  @override
  String get analyticsPeriodWeek => 'Week';

  @override
  String get analyticsPeriodMonth => 'Month';

  @override
  String get analyticsPeriodQuarter => '3 months';

  @override
  String get analyticsPeriodYear => 'Year';

  @override
  String get analyticsPickDates => 'Pick dates';

  @override
  String get analyticsPreviousPeriod => 'Previous period';

  @override
  String get analyticsNextPeriod => 'Next period';

  @override
  String get analyticsNoReceipts => 'No receipts in this period';

  @override
  String get analyticsSpent => 'Spent';

  @override
  String analyticsComparedWith(String period, String amount) {
    return '$period: $amount';
  }

  @override
  String analyticsNothingBefore(String period) {
    return 'Nothing spent in the period before ($period)';
  }

  @override
  String analyticsChangeVs(String change, String period) {
    return '$change vs $period';
  }

  @override
  String get analyticsOverTime => 'Over time';

  @override
  String get analyticsOverTimeHint => 'Tap a bar to see its total';

  @override
  String get analyticsCategoriesTitle => 'Categories';

  @override
  String get analyticsUncategorised => 'Uncategorised and other';

  @override
  String get analyticsStoresTitle => 'Stores';

  @override
  String get analyticsUnknownStore => 'Unknown store';

  @override
  String analyticsStoreVisits(int count, String amount) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count visits',
      one: '1 visit',
    );
    return '$_temp0 · average $amount';
  }

  @override
  String get analyticsSavingsTitle => 'Saved with discounts';

  @override
  String analyticsSavingsRate(String percent) {
    return '$percent of the full price';
  }

  @override
  String get analyticsMostBoughtTitle => 'Most bought';

  @override
  String analyticsTimesBought(int count, String date) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count times',
      one: 'once',
    );
    return '$_temp0 · last bought $date';
  }

  @override
  String analyticsShowAll(int count) {
    return 'Show all ($count)';
  }

  @override
  String get analyticsShowLess => 'Show less';

  @override
  String get analyticsPriceChangesTitle => 'Price changes';

  @override
  String get analyticsPriceRises => 'Going up';

  @override
  String get analyticsPriceDrops => 'Going down';

  @override
  String analyticsPriceVsUsual(String latest, String usual) {
    return '$latest vs $usual usually';
  }

  @override
  String get analyticsPriceChangesHint =>
      'Full price of the latest purchase against the median of the 90 days before (at least 3 purchases). Offers don\'t count.';

  @override
  String get analyticsNoPriceChanges =>
      'No notable price changes in this period';

  @override
  String get analyticsTabPantry => 'Pantry';

  @override
  String get analyticsPantryEmpty =>
      'The pantry is empty.\nSave a receipt to see what you use and what you throw away.';

  @override
  String get analyticsFateTitle => 'Where the spending went';

  @override
  String analyticsFateSubtitle(String amount) {
    return '$amount spent in this period';
  }

  @override
  String get analyticsFateUsed => 'Used';

  @override
  String get analyticsFateWasted => 'Thrown away';

  @override
  String get analyticsFateInPantry => 'Still in the pantry';

  @override
  String get analyticsFateNotInPantry => 'Not in the pantry';

  @override
  String get analyticsFateNotInPantryHint =>
      'untracked products, basket discounts and rows with no product';

  @override
  String analyticsFateCoverage(int untouched, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      untouched,
      locale: localeName,
      other:
          '$untouched products of $count were never updated: they count as still in the pantry.',
      one:
          '1 product of $count was never updated: it counts as still in the pantry.',
      zero: 'All $count products were updated in the pantry.',
    );
    return '$_temp0';
  }

  @override
  String get analyticsFateNoReceipts => 'No receipts in this period';

  @override
  String get analyticsWasteTitle => 'Waste';

  @override
  String get analyticsWasteSubtitle =>
      'Thrown away in this period, whenever it was bought';

  @override
  String analyticsWasteRate(String percent) {
    return '$percent of what left the pantry';
  }

  @override
  String get analyticsWasteNone => 'Nothing thrown away in this period';

  @override
  String analyticsWasteUnpriced(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Plus $count products with no price',
      one: 'Plus 1 product with no price',
    );
    return '$_temp0';
  }

  @override
  String get analyticsWasteReasons => 'Why';

  @override
  String get analyticsWasteReasonExpired => 'Expired';

  @override
  String get analyticsWasteReasonSpoiled => 'Spoiled';

  @override
  String get analyticsWasteReasonOther => 'Other';

  @override
  String get analyticsWasteCategories => 'By category';

  @override
  String get analyticsWasteProducts => 'Most thrown away';

  @override
  String analyticsWasteLots(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count times',
      one: 'once',
    );
    return '$_temp0';
  }

  @override
  String get analyticsNoCategory => 'No category';

  @override
  String get shoppingTitle => 'Next shopping';

  @override
  String get shoppingEmpty => 'Nothing to buy again in the next few days';

  @override
  String get shoppingHint =>
      'Based on what you use from the pantry and how often you buy';

  @override
  String get shoppingFinished => 'Finished in the pantry';

  @override
  String shoppingRunningLow(String quantity, String when) {
    return '$quantity left: runs out $when';
  }

  @override
  String shoppingUsual(int days, String date) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days days',
      one: 'day',
    );
    return 'Usually every $_temp0, last on $date';
  }

  @override
  String shoppingEvery(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days days',
      one: 'day',
    );
    return 'usually every $_temp0';
  }

  @override
  String get shoppingToday => 'today';

  @override
  String get shoppingTomorrow => 'tomorrow';

  @override
  String shoppingInDays(int days) {
    return 'in $days days';
  }

  @override
  String insightSpikeTitle(String category, String change) {
    return '$category: $change vs usual';
  }

  @override
  String insightSpikeBody(String amount, String usual, int months) {
    String _temp0 = intl.Intl.pluralLogic(
      months,
      locale: localeName,
      other: 'average of the last $months months',
      one: 'last month',
    );
    return '$amount so far this month; usually $usual by now ($_temp0)';
  }

  @override
  String insightWasteTitle(String product) {
    return 'Often thrown away: $product';
  }

  @override
  String insightWasteBody(int wasted, int total, int days, String amount) {
    return '$wasted times out of $total in the last $days days, $amount thrown away. Try buying less.';
  }

  @override
  String insightPriceTitle(String product) {
    return 'Price going up: $product';
  }

  @override
  String insightPriceBody(
    String latest,
    String usual,
    String store,
    String change,
    String amount,
  ) {
    String _temp0 = intl.Intl.selectLogic(store, {
      'none': '',
      'other': ' at $store',
    });
    return '$latest vs $usual usually$_temp0 ($change). About $amount more a month for what you buy.';
  }

  @override
  String get exportTitle => 'Export the collected data';

  @override
  String exportSummary(int receipts, int items) {
    String _temp0 = intl.Intl.pluralLogic(
      receipts,
      locale: localeName,
      other: '$receipts receipts',
      one: '1 receipt',
    );
    String _temp1 = intl.Intl.pluralLogic(
      items,
      locale: localeName,
      other: '$items items',
      one: '1 item',
    );
    return '$_temp0 · $_temp1, in a CSV file';
  }

  @override
  String get exportNothing => 'No receipts to export';

  @override
  String get exportWarning =>
      'Every item of the confirmed receipts, one per row, in a CSV file that opens in Excel, Google Sheets or an analysis tool.\n\nThe file is not encrypted: anyone who opens it sees your purchases.';

  @override
  String get exportConfirm => 'Export';

  @override
  String exportDone(int count, String fileName) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Exported $count items',
      one: 'Exported 1 item',
    );
    return '$_temp0 to $fileName';
  }

  @override
  String get exportFailed => 'The export failed.';
}
