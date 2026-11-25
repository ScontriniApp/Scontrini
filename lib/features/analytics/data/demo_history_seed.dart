/// A made-up but realistic purchase history, so analytics, insights and their
/// screens can be built and tested before real receipts can be confirmed.
///
/// [demoPurchases] describes the purchases as plain records (no database);
/// [seedDemoHistory] writes them through one function, [_writePurchase],
/// which is the only place to change when the schema or the real save path
/// changes. Everything is relative to `today`, so the dashboard's current
/// month is never empty, and deterministic: the same `today` gives the same
/// rows.
///
/// Scenarios built in (the last 28 days are the "recent" phase):
/// * milk weekly at 1,29 €, 1,45 € recently (+12%): price increase;
/// * coffee every other week at 4,59 €, 3,89 € recently (−15%): price drop;
/// * drinks about 1.5× their usual spend recently: category spike;
/// * meat is the largest category: top category;
/// * more promotions recently: discount usage; one basket coupon;
/// * apples, bananas, chicken and tomatoes by weight (price per kg);
/// * milk printed twice on some receipts (one purchase occasion);
/// * an item with no product and no category, one with a category only;
/// * a receipt whose items don't add up to its total ("Other" slice);
/// * a week with no shopping (empty chart bucket);
/// * a draft receipt (left out of analytics).
///
/// Every confirmed receipt also goes into the pantry, as the scan flow does
/// (one lot per product), with movements up to `today`: fresh food is used
/// within about a week and every fourth lot of it is partly thrown away
/// (vegetables every other one recently: a waste increase), long-life food
/// is used within three weeks, every ninth lot is never updated, and the
/// last two days are untouched. See [_writePantry].
///
/// Returned items are left out: none have been seen on real receipts.
/// The demo stores are the marker that [removeDemoHistory] uses, so real
/// receipts are never touched.
library;

import 'dart:math';

import 'package:drift/drift.dart';
import 'package:scontrini/core/database/app_database.dart';

/// A store of the demo history. The VAT numbers are not real ones.
enum DemoStore {
  aurora('Supermercato Aurora', 'IT00000000017', 'Via dei Tigli 4'),
  borgo('Market Borgo', 'IT00000000025', 'Piazza Grande 12'),
  ponte('Discount Ponte', 'IT00000000033', 'Viale del Ponte 80');

  new(this.storeName, this.vatNumber, this.address);

  final String storeName;
  final String vatNumber;
  final String address;
}

/// A canonical product of the demo history. [categoryName] is one of the
/// seeded categories (`default_categories.dart`).
enum DemoProduct {
  milk('Latte intero 1 l', 'Latticini e uova', 'pz', 'LATTE INTERO 1L'),
  yogurt('Yogurt bianco x2', 'Latticini e uova', 'pz', 'YOGURT BIANCO X2'),
  bread('Pane comune', 'Pane e pasta', 'pz', 'PANE COMUNE'),
  spaghetti('Spaghetti 500 g', 'Pane e pasta', 'pz', 'SPAGHETTI 500G'),
  apples('Mele', 'Frutta e verdura', 'kg', 'MELE GOLDEN'),
  bananas('Banane', 'Frutta e verdura', 'kg', 'BANANE'),
  tomatoes('Pomodori', 'Frutta e verdura', 'kg', 'POMODORI RAMATI'),
  chicken('Petto di pollo', 'Carne e pesce', 'kg', 'PETTO DI POLLO'),
  beef('Macinato di manzo 500 g', 'Carne e pesce', 'pz', 'MACINATO MANZO'),
  salmon('Salmone 200 g', 'Carne e pesce', 'pz', 'SALMONE FILETTI'),
  coffee('Caffè moka 250 g', 'Dispensa', 'pz', 'CAFFE MOKA 250G'),
  water('Acqua naturale 6×1,5 l', 'Bevande', 'pz', 'ACQUA NAT 6X1,5L'),
  beer('Birra 3×33 cl', 'Bevande', 'pz', 'BIRRA 3X33CL'),
  juice('Succo d’arancia 1 l', 'Bevande', 'pz', 'SUCCO ARANCIA 1L'),
  peas('Piselli surgelati 450 g', 'Surgelati', 'pz', 'PISELLI SURG 450G'),
  dishSoap('Detersivo piatti', 'Casa e igiene', 'pz', 'DETERSIVO PIATTI');

  new(this.canonicalName, this.categoryName, this.unit, this.rawName);

  final String canonicalName;
  final String categoryName;

  /// `pz`, `kg` or `l`, as in `products.unit`.
  final String unit;

  /// Name as printed on the receipt; also saved as the product's alias.
  final String rawName;
}

/// One printed item line, as the review screen would save it.
class DemoLine {
  const new({
    required this.rawName,
    required this.unitPriceCents,
    this.product,
    this.categoryName,
    this.quantity = 1,
    this.unit = 'pz',
    this.discountCents = 0,
  });

  /// A line matched to [product], with the product's category and unit.
  new product(
    DemoProduct this.product, {
    required this.unitPriceCents,
    this.quantity = 1,
    this.discountCents = 0,
  }) : rawName = product.rawName,
       categoryName = product.categoryName,
       unit = product.unit;

  final String rawName;

  /// Null for an item the product matcher did not recognise.
  final DemoProduct? product;

  /// Null for an item the classifier could not place.
  final String? categoryName;

  /// Pieces, or kg for weighed items.
  final double quantity;

  /// `pz`, `kg` or `l`, as in `receipt_items.unit`.
  final String unit;

  /// Per piece or per kg.
  final int unitPriceCents;
  final int discountCents;

  int get lineTotalCents => (unitPriceCents * quantity).round();
  int get netCents => lineTotalCents - discountCents;
}

/// One receipt of the demo history.
class DemoPurchase {
  const new({
    required this.store,
    required this.localDate,
    required this.lines,
    this.couponCents = 0,
    this.unreadCents = 0,
    this.status = ReceiptStatus.confirmed,
  });

  final DemoStore store;

  /// When it was bought, in local time.
  final DateTime localDate;
  final List<DemoLine> lines;

  /// Basket coupon (`receipts.discountCents`).
  final int couponCents;

  /// Part of the printed total that no item line accounts for, like an OCR
  /// miss the user accepted.
  final int unreadCents;
  final ReceiptStatus status;

  /// The printed total.
  int get totalCents =>
      lines.fold(0, (sum, l) => sum + l.netCents) - couponCents + unreadCents;
}

/// How many weeks of history [demoPurchases] covers.
const demoWeeks = 26;

/// The demo purchases for the 26 weeks ending on [today] (local day), oldest
/// first. Nothing is after [today]. Deterministic for a given day.
List<DemoPurchase> demoPurchases(DateTime today) {
  final rng = Random(42);
  final lastDay = DateTime(today.year, today.month, today.day);
  final firstDay = DateTime(
    lastDay.year,
    lastDay.month,
    lastDay.day - demoWeeks * 7 + 1,
  );
  final recentStart = DateTime(lastDay.year, lastDay.month, lastDay.day - 27);

  // Weight between [min] and [max] kg, to 5 g.
  double kg(double min, double max) =>
      ((min + rng.nextDouble() * (max - min)) * 200).round() / 200;

  final purchases = <DemoPurchase>[];
  var mainShops = 0;
  var couponGiven = false;
  var unreadGiven = false;
  for (
    var day = firstDay;
    !day.isAfter(lastDay);
    day = DateTime(day.year, day.month, day.day + 1)
  ) {
    final daysBack = lastDay.difference(day).inDays;
    final week = daysBack ~/ 7;
    if (week == 10) continue; // a week with no shopping
    final recent = !day.isBefore(recentStart);

    if (day.weekday == DateTime.saturday) {
      final n = mainShops++;
      final promoWeek = recent || n % 4 == 0;
      final lines = <DemoLine>[
        DemoLine.product(DemoProduct.milk, unitPriceCents: recent ? 145 : 129),
        if (n % 4 == 1)
          // Printed twice, as tills do for a second scan of the same item.
          DemoLine.product(
            DemoProduct.milk,
            unitPriceCents: recent ? 145 : 129,
          ),
        DemoLine.product(DemoProduct.bread, unitPriceCents: 180),
        DemoLine.product(
          DemoProduct.spaghetti,
          unitPriceCents: 89,
          quantity: 2,
          discountCents: recent ? 54 : 0,
        ),
        DemoLine.product(
          DemoProduct.yogurt,
          unitPriceCents: 139,
          discountCents: promoWeek ? 42 : 0,
        ),
        DemoLine.product(
          DemoProduct.apples,
          unitPriceCents: 229,
          quantity: kg(0.6, 1.4),
        ),
        DemoLine.product(
          DemoProduct.chicken,
          unitPriceCents: 1090,
          quantity: kg(0.4, 0.8),
        ),
        if (n.isEven) DemoLine.product(DemoProduct.beef, unitPriceCents: 650),
        if (n % 3 == 0)
          DemoLine.product(
            DemoProduct.salmon,
            unitPriceCents: 549,
            discountCents: promoWeek ? 110 : 0,
          ),
        if (n.isOdd)
          DemoLine.product(
            DemoProduct.coffee,
            unitPriceCents: recent ? 389 : 459,
          ),
        DemoLine.product(DemoProduct.water, unitPriceCents: 199),
        if (recent) ...[
          DemoLine.product(DemoProduct.beer, unitPriceCents: 399),
          DemoLine.product(DemoProduct.juice, unitPriceCents: 179),
        ] else if (n % 3 == 1)
          DemoLine.product(DemoProduct.juice, unitPriceCents: 179),
        if (n % 3 == 2) DemoLine.product(DemoProduct.peas, unitPriceCents: 219),
        if (n % 4 == 3)
          DemoLine.product(DemoProduct.dishSoap, unitPriceCents: 249),
        if (n % 5 == 2)
          // Recognised as vegetables by keyword, but matched to no product.
          const DemoLine(
            rawName: 'ZUCCHINE',
            categoryName: 'Frutta e verdura',
            quantity: 0.5,
            unit: 'kg',
            unitPriceCents: 249,
          ),
        if (n == 7)
          // Neither matched nor classified.
          const DemoLine(rawName: 'ART. 004512', unitPriceCents: 350),
      ];

      // One basket coupon, about two months back.
      final coupon = !couponGiven && daysBack < 70;
      couponGiven |= coupon;
      // One receipt the OCR misread a line of, about three months back.
      final unread = !unreadGiven && daysBack < 100;
      unreadGiven |= unread;

      purchases.add(
        DemoPurchase(
          store: n.isEven ? DemoStore.aurora : DemoStore.borgo,
          localDate: DateTime(day.year, day.month, day.day, 10, 30),
          lines: lines,
          couponCents: coupon ? 300 : 0,
          unreadCents: unread ? 120 : 0,
        ),
      );
    } else if (day.weekday == DateTime.wednesday && week % 3 != 2) {
      purchases.add(
        DemoPurchase(
          store: DemoStore.ponte,
          localDate: DateTime(day.year, day.month, day.day, 18, 15),
          lines: [
            DemoLine.product(
              DemoProduct.milk,
              unitPriceCents: recent ? 145 : 129,
            ),
            DemoLine.product(DemoProduct.bread, unitPriceCents: 180),
            DemoLine.product(
              DemoProduct.bananas,
              unitPriceCents: 189,
              quantity: kg(0.8, 1.2),
            ),
            if (week.isEven)
              DemoLine.product(
                DemoProduct.tomatoes,
                unitPriceCents: 249,
                quantity: kg(0.5, 1),
              ),
          ],
        ),
      );
    }
  }

  // Scanned today but not reviewed yet.
  purchases.add(
    DemoPurchase(
      store: DemoStore.ponte,
      localDate: DateTime(lastDay.year, lastDay.month, lastDay.day, 8),
      lines: [DemoLine.product(DemoProduct.milk, unitPriceCents: 999)],
      status: ReceiptStatus.draft,
    ),
  );
  return purchases;
}

/// What [seedDemoHistory] wrote.
typedef DemoSeedResult = ({int confirmed, int drafts, int items});

/// Writes [demoPurchases] for [today] into [db], replacing any demo history
/// already there. Products and aliases that already exist (same canonical
/// name or raw name) are reused, not duplicated.
Future<DemoSeedResult> seedDemoHistory(
  AppDatabase db, {
  required DateTime today,
}) => db.transaction(() async {
  await removeDemoHistory(db);
  final purchases = demoPurchases(today);

  final categoryIds = {
    for (final c in await db.select(db.categories).get()) c.name: c.id,
  };
  final storeIds = <DemoStore, int>{
    for (final s in DemoStore.values)
      s: await db
          .into(db.stores)
          .insert(
            StoresCompanion.insert(
              name: s.storeName,
              vatNumber: Value(s.vatNumber),
              address: Value(s.address),
            ),
          ),
  };
  final productIds = <DemoProduct, int>{
    for (final p in DemoProduct.values) p: await _productId(db, p, categoryIds),
  };

  var items = 0;
  var lots = 0;
  for (final purchase in purchases) {
    final rows = await _writePurchase(
      db,
      purchase,
      storeIds,
      productIds,
      categoryIds,
    );
    items += purchase.lines.length;
    if (purchase.status == ReceiptStatus.confirmed) {
      lots = await _writePantry(
        db,
        purchase,
        rows,
        productIds,
        categoryIds,
        today,
        lots,
      );
    }
  }
  final drafts = purchases.where((p) => p.status == ReceiptStatus.draft).length;
  return (confirmed: purchases.length - drafts, drafts: drafts, items: items);
});

/// Deletes the receipts of the demo stores (their items go with them), the
/// demo stores, and the demo products no other receipt uses (their aliases go
/// with them). Real receipts are never touched.
Future<void> removeDemoHistory(AppDatabase db) => db.transaction(() async {
  final vatNumbers = [for (final s in DemoStore.values) s.vatNumber];
  final stores = await (db.select(
    db.stores,
  )..where((s) => s.vatNumber.isIn(vatNumbers))).get();
  final storeIds = [for (final s in stores) s.id];
  if (storeIds.isNotEmpty) {
    await (db.delete(db.receipts)..where((r) => r.storeId.isIn(storeIds))).go();
    await (db.delete(db.stores)..where((s) => s.id.isIn(storeIds))).go();
  }

  final names = [for (final p in DemoProduct.values) p.canonicalName];
  final used = db.selectOnly(db.receiptItems, distinct: true)
    ..addColumns([db.receiptItems.productId])
    ..where(db.receiptItems.productId.isNotNull());
  await (db.delete(
    db.products,
  )..where((p) => p.canonicalName.isIn(names) & p.id.isNotInQuery(used))).go();
});

Future<int> _productId(
  AppDatabase db,
  DemoProduct product,
  Map<String, int> categoryIds,
) async {
  final existing =
      await (db.select(db.products)
            ..where((p) => p.canonicalName.equals(product.canonicalName)))
          .getSingleOrNull();
  final id =
      existing?.id ??
      await db
          .into(db.products)
          .insert(
            ProductsCompanion.insert(
              canonicalName: product.canonicalName,
              categoryId: Value(categoryIds[product.categoryName]),
              unit: Value(product.unit),
            ),
          );
  await db
      .into(db.productAliases)
      .insert(
        ProductAliasesCompanion.insert(rawName: product.rawName, productId: id),
        mode: InsertMode.insertOrIgnore,
      );
  return id;
}

/// Writes one purchase as the review screen will save a confirmed receipt.
/// The only place that maps demo records to rows: with schema v2, add
/// `receipts.transactionHash` here; once the real save path exists, call
/// it from here instead. Returns the receipt id and each line's row id.
Future<({int receiptId, List<int> itemIds})> _writePurchase(
  AppDatabase db,
  DemoPurchase purchase,
  Map<DemoStore, int> storeIds,
  Map<DemoProduct, int> productIds,
  Map<String, int> categoryIds,
) async {
  final receiptId = await db
      .into(db.receipts)
      .insert(
        ReceiptsCompanion.insert(
          storeId: Value(storeIds[purchase.store]),
          purchaseDate: purchase.localDate.toUtc(),
          totalCents: purchase.totalCents,
          discountCents: Value(purchase.couponCents),
          status: purchase.status,
        ),
      );
  final itemIds = <int>[
    for (final line in purchase.lines)
      await db
          .into(db.receiptItems)
          .insert(
            ReceiptItemsCompanion.insert(
              receiptId: receiptId,
              productId: Value(productIds[line.product]),
              rawName: line.rawName,
              quantity: Value(line.quantity),
              unit: Value(line.unit),
              unitPriceCents: line.unitPriceCents,
              lineTotalCents: line.lineTotalCents,
              discountCents: Value(line.discountCents),
              categoryId: Value(categoryIds[line.categoryName]),
            ),
          ),
  ];
  return (receiptId: receiptId, itemIds: itemIds);
}

/// Fresh food: used within about a week, sometimes thrown away.
const Set<DemoProduct> _perishable = {
  DemoProduct.milk,
  DemoProduct.yogurt,
  DemoProduct.bread,
  DemoProduct.apples,
  DemoProduct.bananas,
  DemoProduct.tomatoes,
  DemoProduct.chicken,
  DemoProduct.beef,
  DemoProduct.salmon,
};

const Set<DemoProduct> _vegetables = {
  DemoProduct.apples,
  DemoProduct.bananas,
  DemoProduct.tomatoes,
};

/// Puts [purchase]'s products in the pantry, one lot per product (as
/// `PantryRepository.addAllFromReceipt` does), and writes their movements
/// up to [today]. [seq] counts lots across the whole history, so the
/// pattern is deterministic; returns it advanced. Lines matched to no
/// product go in but are never moved.
Future<int> _writePantry(
  AppDatabase db,
  DemoPurchase purchase,
  ({int receiptId, List<int> itemIds}) rows,
  Map<DemoProduct, int> productIds,
  Map<String, int> categoryIds,
  DateTime today,
  int seq,
) async {
  // Lines of one product (or one printed name) and unit are one lot.
  final groups = <String, List<int>>{};
  for (final (i, line) in purchase.lines.indexed) {
    final key = '${line.product?.name ?? line.rawName}|${line.unit}';
    (groups[key] ??= []).add(i);
  }

  final bought = purchase.localDate;
  final now = today.toLocal();
  final age = DateTime.utc(
    now.year,
    now.month,
    now.day,
  ).difference(DateTime.utc(bought.year, bought.month, bought.day)).inDays;
  var next = seq;
  for (final indexes in groups.values) {
    final lines = [for (final i in indexes) purchase.lines[i]];
    final first = lines.first;
    final product = first.product;
    final quantity = _round(
      lines.fold<double>(0, (sum, l) => sum + l.quantity),
    );
    final lotId = await db
        .into(db.pantryLots)
        .insert(
          PantryLotsCompanion.insert(
            receiptId: Value(rows.receiptId),
            productId: Value(productIds[product]),
            categoryId: Value(categoryIds[first.categoryName]),
            name: product?.canonicalName ?? first.rawName,
            unit: Value(first.unit),
            source: PantrySource.receipt,
            initialQuantity: quantity,
            priceCents: Value(lines.fold<int>(0, (sum, l) => sum + l.netCents)),
            addedAt: bought.toUtc(),
          ),
        );
    await (db.update(db.receiptItems)
          ..where((r) => r.id.isIn([for (final i in indexes) rows.itemIds[i]])))
        .write(ReceiptItemsCompanion(pantryLotId: Value(lotId)));

    Future<void> event(
      PantryEventKind kind,
      double delta,
      int day, {
      PantryEventReason? reason,
    }) => db
        .into(db.pantryEvents)
        .insert(
          PantryEventsCompanion.insert(
            lotId: lotId,
            kind: kind,
            reason: Value(reason),
            delta: _round(delta),
            at: DateTime(
              bought.year,
              bought.month,
              bought.day + day,
              20,
            ).toUtc(),
          ),
        );

    await event(PantryEventKind.stockIn, quantity, 0);
    next++;
    if (product == null || next % 9 == 0 || age < 2) continue;

    final fresh = _perishable.contains(product);
    final shelfDays = fresh ? 6 : 20;
    final half = _round(quantity / 2);
    final wasted =
        fresh &&
        (next % 4 == 1 ||
            (age < 28 && _vegetables.contains(product) && next.isOdd));

    await event(PantryEventKind.consume, -half, 2);
    if (age < shelfDays) continue;
    if (wasted) {
      await event(
        PantryEventKind.discard,
        -(quantity - half),
        shelfDays,
        reason: product == DemoProduct.milk || product == DemoProduct.yogurt
            ? PantryEventReason.expired
            : PantryEventReason.spoiled,
      );
    } else {
      await event(PantryEventKind.consume, -(quantity - half), shelfDays - 1);
    }
  }
  return next;
}

double _round(double q) => (q * 1000).round() / 1000;
