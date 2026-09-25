import 'dart:io';

import 'package:doaya_pharmacy/data/catalog_repository.dart';
import 'package:doaya_pharmacy/data/database.dart';
import 'package:doaya_pharmacy/data/people_repository.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

/// Owner's decision: every number in English digits, stored data included.
void main() {
  // "أوميغا ٣", phone "٠٩٤٤", written with escapes so this file stays ASCII-digit only.
  const omega = 'أوميغا ٣';
  const phone = '٠٩٤٤';

  test('v3 → v4 converts Arabic-Indic digits in names, phones and settings', () async {
    final v3 = File('test/fixtures/schema_v3.sql').readAsStringSync();
    final db = AppDatabase(
      NativeDatabase.memory(
        setup: (raw) {
          raw.execute(v3);
          raw.execute(
            "INSERT INTO products (id, trade_name, arabic_name, active_ingredient, price_minor, "
            "prescription_only, low_stock_threshold, active, units_per_pack, created_at, updated_at, "
            "updated_by_device) VALUES ('p', 'Omega 3', '$omega', 'fish oil', 1, 0, 5, 1, 1, "
            "'2026-09-01T00:00:00.000Z', '2026-09-01T00:00:00.000Z', 'd')",
          );
          raw.execute(
            "INSERT INTO customers (id, name, phone, created_at, updated_at) VALUES "
            "('c', 'زبون', '$phone', '2026-09-01T00:00:00.000Z', '2026-09-01T00:00:00.000Z')",
          );
          raw.execute("INSERT INTO settings (key, value) VALUES ('pharmacy_name', 'صيدلية ١')");
          raw.execute('PRAGMA user_version = 3');
        },
      ),
    );
    addTearDown(db.close);
    expect((await CatalogRepository(db).byId('p'))!.arabicName, 'أوميغا 3');
    expect((await PeopleRepository(db).customer('c'))!.phone, '0944');
    expect(await PeopleRepository(db).setting('pharmacy_name'), 'صيدلية 1');
  });

  test('new data is stored with English digits; search accepts either', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final catalog = CatalogRepository(db);
    final p = await catalog.create(
      const ProductDraft(
        tradeName: 'Omega 3',
        arabicName: omega,
        activeIngredient: 'fish oil',
        priceMinor: 100,
        barcodes: ['٦٢٢١'],
      ),
      deviceId: 'd',
    );
    expect(p.arabicName, 'أوميغا 3');
    expect((await catalog.byBarcode('6221'))!.id, p.id);
    expect((await catalog.search(omega)).single.id, p.id);
    final c = await PeopleRepository(db).addCustomer(name: 'زبون', phone: phone);
    expect(c.phone, '0944');
  });
}
