import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift_dev/api/migrations_native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scontrini/core/database/app_database.dart';

import '../../generated_migrations/schema.dart';
import '../../generated_migrations/schema_v1.dart' as v1;

/// Schemas are snapshots in `drift_schemas/`. After changing the tables:
/// bump `schemaVersion`, then
/// `dart run drift_dev schema dump lib/core/database/app_database.dart drift_schemas/`
/// and `dart run drift_dev schema generate --data-classes --companions
/// drift_schemas/ test/generated_migrations/`.
void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  late SchemaVerifier verifier;

  setUpAll(() => verifier = SchemaVerifier(GeneratedHelper()));

  test('upgrade from v1 to v2 matches a fresh v2 schema', () async {
    final connection = await verifier.startAt(1);
    final db = AppDatabase(connection);
    await verifier.migrateAndValidate(db, 2);
    await db.close();
  });

  test('v1 receipt rows survive the upgrade', () async {
    final schema = await verifier.schemaAt(1);
    final old = v1.DatabaseAtV1(schema.newConnection());
    final receiptId = await old
        .into(old.receipts)
        .insert(
          v1.ReceiptsCompanion.insert(
            purchaseDate:
                DateTime.utc(2026, 11, 18).millisecondsSinceEpoch ~/ 1000,
            totalCents: 129,
            status: 'confirmed',
          ),
        );
    await old
        .into(old.receiptItems)
        .insert(
          v1.ReceiptItemsCompanion.insert(
            receiptId: receiptId,
            rawName: 'LATTE',
            unitPriceCents: 129,
            lineTotalCents: 129,
          ),
        );
    await old.close();

    final db = AppDatabase(schema.newConnection());
    final item = await db.select(db.receiptItems).getSingle();
    expect(item.rawName, 'LATTE');
    expect(item.unit, 'pz');
    expect(item.pantryLotId, isNull);
    await db.close();
  });
}
