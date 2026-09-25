import 'package:doaya_core/doaya_core.dart';
import 'package:drift/drift.dart';

import 'database.dart';

/// Input for creating/editing a product.
class ProductDraft {
  const ProductDraft({
    required this.tradeName,
    required this.activeIngredient,
    required this.priceMinor,
    this.arabicName,
    this.strength,
    this.form,
    this.manufacturer,
    this.shelf,
    this.prescriptionOnly = false,
    this.lowStockThreshold = 5,
    this.barcodes = const [],
    this.unitsPerPack = 1,
    this.stripPriceMinor,
  });

  final String tradeName;
  final String activeIngredient;
  final int priceMinor;
  final String? arabicName;
  final String? strength;
  final String? form;
  final String? manufacturer;
  final String? shelf;
  final bool prescriptionOnly;
  final int lowStockThreshold;
  final List<String> barcodes;

  /// Strips per box (1 = whole boxes only).
  final int unitsPerPack;
  final int? stripPriceMinor;
}

/// Strips-per-box can't change once stock moved: every stored quantity is in
/// strips and would silently change meaning.
class UnitsPerPackLocked implements Exception {
  const UnitsPerPackLocked();
}

class DuplicateBarcode implements Exception {
  const DuplicateBarcode(this.barcode, this.productId);
  final String barcode;
  final String productId;
}

class CatalogRepository {
  CatalogRepository(this._db, {UuidV7? ids, DateTime Function()? clock})
    : _ids = ids ?? UuidV7(),
      _clock = clock ?? DateTime.now;

  final AppDatabase _db;
  final UuidV7 _ids;
  final DateTime Function() _clock;

  Future<ProductRow> create(ProductDraft d, {required String deviceId}) async {
    final id = _ids.generate();
    final now = _clock();
    await _db.transaction(() async {
      await _db
          .into(_db.products)
          .insert(
            ProductsCompanion.insert(
              id: id,
              tradeName: cleanText(d.tradeName) ?? '',
              arabicName: Value(_blankToNull(d.arabicName)),
              activeIngredient: _normalizeIngredient(d.activeIngredient),
              strength: Value(_blankToNull(d.strength)),
              form: Value(_blankToNull(d.form)),
              manufacturer: Value(_blankToNull(d.manufacturer)),
              shelf: Value(_blankToNull(d.shelf)),
              priceMinor: d.priceMinor,
              prescriptionOnly: Value(d.prescriptionOnly),
              lowStockThreshold: Value(d.lowStockThreshold),
              unitsPerPack: Value(d.unitsPerPack < 1 ? 1 : d.unitsPerPack),
              stripPriceMinor: Value(d.unitsPerPack > 1 ? d.stripPriceMinor : null),
              createdAt: now,
              updatedAt: now,
              updatedByDevice: deviceId,
            ),
          );
      await _setBarcodes(id, d.barcodes);
    });
    return (await byId(id))!;
  }

  Future<void> update(String id, ProductDraft d, {required String deviceId}) async {
    await _db.transaction(() async {
      final current = await byId(id);
      if (current != null && current.unitsPerPack != d.unitsPerPack && await hasMovements(id)) {
        throw const UnitsPerPackLocked();
      }
      await (_db.update(_db.products)..where((t) => t.id.equals(id))).write(
        ProductsCompanion(
          tradeName: Value(cleanText(d.tradeName) ?? ''),
          arabicName: Value(_blankToNull(d.arabicName)),
          activeIngredient: Value(_normalizeIngredient(d.activeIngredient)),
          strength: Value(_blankToNull(d.strength)),
          form: Value(_blankToNull(d.form)),
          manufacturer: Value(_blankToNull(d.manufacturer)),
          shelf: Value(_blankToNull(d.shelf)),
          priceMinor: Value(d.priceMinor),
          prescriptionOnly: Value(d.prescriptionOnly),
          lowStockThreshold: Value(d.lowStockThreshold),
          unitsPerPack: Value(d.unitsPerPack < 1 ? 1 : d.unitsPerPack),
          stripPriceMinor: Value(d.unitsPerPack > 1 ? d.stripPriceMinor : null),
          updatedAt: Value(_clock()),
          updatedByDevice: Value(deviceId),
        ),
      );
      await (_db.delete(_db.productBarcodes)..where((t) => t.productId.equals(id))).go();
      await _setBarcodes(id, d.barcodes);
    });
  }

  Future<void> _setBarcodes(String productId, List<String> codes) async {
    for (final raw
        in codes.map((c) => toLatinDigits(c.trim())).where((c) => c.isNotEmpty).toSet()) {
      final existing = await (_db.select(
        _db.productBarcodes,
      )..where((t) => t.barcode.equals(raw))).getSingleOrNull();
      if (existing != null && existing.productId != productId) {
        throw DuplicateBarcode(raw, existing.productId);
      }
      await _db
          .into(_db.productBarcodes)
          .insertOnConflictUpdate(
            ProductBarcodesCompanion.insert(barcode: raw, productId: productId),
          );
    }
  }

  Future<bool> hasMovements(String productId) async =>
      (await (_db.select(_db.stockEvents)
                ..where((t) => t.productId.equals(productId))
                ..limit(1))
              .get())
          .isNotEmpty;

  Future<ProductRow?> byId(String id) =>
      (_db.select(_db.products)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<ProductRow?> byBarcode(String barcode) async {
    final q = _db.select(_db.products).join([
      innerJoin(_db.productBarcodes, _db.productBarcodes.productId.equalsExp(_db.products.id)),
    ])..where(_db.productBarcodes.barcode.equals(toLatinDigits(barcode.trim())));
    final row = await q.getSingleOrNull();
    return row?.readTable(_db.products);
  }

  Future<List<String>> barcodesOf(String productId) async => (await (_db.select(
    _db.productBarcodes,
  )..where((t) => t.productId.equals(productId))).get()).map((r) => r.barcode).toList();

  Stream<List<ProductRow>> watchAll() =>
      (_db.select(_db.products)
            ..where((t) => t.active.equals(true))
            ..orderBy([(t) => OrderingTerm.asc(t.tradeName)]))
          .watch();

  /// Search by trade name, Arabic name, active ingredient or exact barcode.
  Future<List<ProductRow>> search(String query, {int limit = 30}) async {
    final q = toLatinDigits(query.trim());
    if (q.isEmpty) return const [];
    final byCode = await byBarcode(q);
    final pattern = '%${q.replaceAll('%', r'\%').replaceAll('_', r'\_')}%';
    final rows =
        await (_db.select(_db.products)
              ..where(
                (t) =>
                    t.active.equals(true) &
                    (t.tradeName.like(pattern) |
                        t.arabicName.like(pattern) |
                        t.activeIngredient.like(pattern)),
              )
              ..orderBy([(t) => OrderingTerm.asc(t.tradeName)])
              ..limit(limit))
            .get();
    return [?byCode, ...rows.where((r) => r.id != byCode?.id)];
  }

  /// Other active products with the same active ingredient.
  Future<List<ProductRow>> alternatives(ProductRow p) =>
      (_db.select(_db.products)
            ..where(
              (t) =>
                  t.active.equals(true) &
                  t.activeIngredient.equals(p.activeIngredient) &
                  t.id.equals(p.id).not(),
            )
            ..orderBy([(t) => OrderingTerm.asc(t.tradeName)]))
          .get();

  static String? _blankToNull(String? s) => cleanText(s);

  /// Lower-case, single spaces: "Amoxicillin  " and "amoxicillin" match.
  static String _normalizeIngredient(String s) =>
      toLatinDigits(s.trim()).toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
}
