import 'catalog_repository.dart';
import 'ledger_repository.dart';
import 'people_repository.dart';

/// Sample catalogue + stock for trying the app (owner can load it once from
/// settings while the catalogue is empty). Prices in new SYP minor units.
Future<void> seedDemoData(
  CatalogRepository catalog,
  LedgerRepository ledger,
  PeopleRepository people,
  Session session,
) async {
  final now = ledger.now();
  DateTime inDays(int d) => DateTime.utc(now.year, now.month, now.day).add(Duration(days: d));

  final items = <(ProductDraft, List<(int, int?)>)>[
    (
      const ProductDraft(
        tradeName: 'Amoxil 500 mg',
        arabicName: 'أموكسيل',
        activeIngredient: 'amoxicillin',
        strength: '500 mg',
        form: 'كبسولات',
        shelf: 'B3',
        priceMinor: 4500,
        prescriptionOnly: true,
        barcodes: ['6221000000011'],
      ),
      [(6, 40), (18, 400)],
    ),
    (
      const ProductDraft(
        tradeName: 'Ospamox 500 mg',
        activeIngredient: 'amoxicillin',
        strength: '500 mg',
        shelf: 'B3',
        priceMinor: 4200,
        prescriptionOnly: true,
        barcodes: ['6221000000028'],
      ),
      [(10, 300)],
    ),
    (
      const ProductDraft(
        tradeName: 'Augmentin 1 g',
        activeIngredient: 'amoxicillin + clavulanate',
        strength: '1 g',
        shelf: 'B4',
        priceMinor: 12500,
        prescriptionOnly: true,
        barcodes: ['6221000000035'],
      ),
      [],
    ),
    (
      const ProductDraft(
        tradeName: 'Panadol 500 mg',
        arabicName: 'بنادول',
        activeIngredient: 'paracetamol',
        strength: '500 mg',
        form: 'مضغوطات',
        shelf: 'A1',
        priceMinor: 1800,
        lowStockThreshold: 10,
        barcodes: ['6221000000042'],
      ),
      [(8, 25), (40, 500)],
    ),
    (
      const ProductDraft(
        tradeName: 'Brufen 400 mg',
        arabicName: 'بروفين',
        activeIngredient: 'ibuprofen',
        strength: '400 mg',
        shelf: 'A2',
        priceMinor: 2600,
        barcodes: ['6221000000059'],
      ),
      [(3, 200)],
    ),
    (
      const ProductDraft(
        tradeName: 'Zyrtec 10 mg',
        activeIngredient: 'cetirizine',
        strength: '10 mg',
        shelf: 'C1',
        priceMinor: 3300,
        barcodes: ['6221000000066'],
      ),
      [(12, -5)],
    ),
    (
      const ProductDraft(
        tradeName: 'Omega 3',
        arabicName: 'أوميغا ٣',
        activeIngredient: 'fish oil',
        form: 'كبسولات جيلاتينية',
        shelf: 'D1',
        priceMinor: 9500,
        barcodes: ['6221000000073'],
      ),
      [(20, null)],
    ),
  ];

  for (final (draft, batches) in items) {
    final p = await catalog.create(draft, deviceId: session.deviceId);
    for (final (qty, days) in batches) {
      await ledger.receive(
        session,
        productId: p.id,
        quantity: qty,
        expiry: days == null ? null : inDays(days),
      );
    }
  }
  await people.addCustomer(name: 'أبو أحمد', phone: '0944000111');
  await people.addCustomer(name: 'أم سامر', phone: '0933000222');
}
