import 'dart:convert';

import 'package:doaya_patient/data/models.dart';
import 'package:doaya_patient/data/patient_api.dart';
import 'package:doaya_patient/data/providers.dart';
import 'package:doaya_patient/data/session_store.dart';
import 'package:doaya_patient/data/shop.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'app_flow_test.dart' show FakeServer;
import 'auth_test.dart' show pharmacy;
import 'live_updates_test.dart' show until;
import 'patient_api_test.dart' show patientJson;

Future<ProviderContainer> signedIn(FakeServer server) async {
  server.me = {...patientJson, 'pharmacy': pharmacy};
  final store = MemorySessionStore();
  await store.write(jsonEncode({'session_token': 's.x', 'patient': server.me}));
  final c = ProviderContainer(
    overrides: [
      apiProvider.overrideWithValue(PatientApi(Uri.parse('https://x/'), client: server.client)),
      sessionStoreProvider.overrideWithValue(store),
    ],
  );
  addTearDown(c.dispose);
  c.read(authProvider);
  await until(() => c.read(authProvider).signedIn);
  return c;
}

void main() {
  test('the shelf: available first, search, one product', () async {
    final server = FakeServer();
    final c = await signedIn(server);
    final all = await c.read(shelfProvider('').future);
    expect(all.map((i) => (i.tradeName, i.available)), [
      ('Panadol 500mg', true),
      ('Omega 3', true),
      ('Augmentin 1g', false),
    ]);
    expect(all.last.prescriptionOnly, isTrue);
    expect((await c.read(shelfProvider('بنادول').future)).single.productId, 'p1');
    expect((await c.read(shelfItemProvider('p2').future)).priceMinor, 1200000);
    expect(server.seen, contains('GET /directory/ph1/shelf/p2'));
  });

  test('the cart: add, change, drop; the order goes out and empties it', () async {
    final server = FakeServer();
    final c = await signedIn(server);
    final shelf = await c.read(shelfProvider('').future);
    final cart = c.read(cartProvider.notifier);
    cart
      ..add(shelf[0])
      ..add(shelf[0])
      ..add(shelf[1]);
    expect(c.read(cartCountProvider), 3);
    expect(c.read(cartTotalProvider), 2 * 250000 + 1200000);
    cart
      ..set(shelf[1], 0)
      ..set(shelf[0], 500);
    expect(c.read(cartProvider).keys, ['p1']);
    expect(c.read(cartProvider)['p1']!.quantity, Cart.maxQuantity);
    cart.set(shelf[0], 3);

    final o = await cart.order(note: '  بعد العصر  ');
    expect((o.status, o.note, o.totalMinor), ('sent', 'بعد العصر', 750000));
    expect(o.lines.single.requested, 3);
    expect(c.read(cartProvider), isEmpty);
    expect((await c.read(ordersProvider.future)).single.id, o.id);

    // The patient can cancel until the pharmacist handles it.
    c.listen(orderProvider(o.id), (_, _) {});
    await c.read(orderProvider(o.id).future);
    await c.read(orderProvider(o.id).notifier).cancel();
    expect(c.read(orderProvider(o.id)).value!.status, OrderStatus.cancelled);
    await expectLater(
      c.read(orderProvider(o.id).notifier).cancel(),
      throwsA(isA<SyncApiException>().having((e) => e.code, 'code', 'already_handled')),
    );
  });

  test('changing pharmacy empties the cart', () async {
    final server = FakeServer();
    final c = await signedIn(server);
    c.listen(cartProvider, (_, _) {});
    c.read(cartProvider.notifier).add((await c.read(shelfProvider('').future)).first);
    expect(c.read(cartProvider), hasLength(1));
    await c
        .read(authProvider.notifier)
        .choosePharmacy(PharmacyBrief.fromJson({...pharmacy, 'id': 'ph2', 'name': 'صيدلية تانية'}));
    expect(c.read(cartProvider), isEmpty);
  });

  test('order lines tell what the pharmacist changed', () {
    final line = OrderLine.fromJson({
      'product_id': 'p1',
      'name': 'Panadol',
      'requested': 2,
      'quantity': 1,
      'price_minor': 100,
    });
    expect(line.changed, isTrue);
  });
}
