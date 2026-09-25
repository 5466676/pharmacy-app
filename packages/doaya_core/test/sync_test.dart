import 'package:doaya_core/doaya_core.dart';
import 'package:doaya_core/sync_testing.dart';
import 'package:test/test.dart';

void main() {
  late InMemorySyncServer server;
  var now = DateTime.utc(2026, 9, 25, 10);
  DateTime clock() => now;

  InMemorySyncStore device(String id) => InMemorySyncStore(id, clock: clock);
  SyncEngine engine(InMemorySyncStore s, {int batch = 500, int limit = 500}) =>
      SyncEngine(s, server.transportFor(s.deviceId), pushBatch: batch, pullLimit: limit);

  setUp(() {
    server = InMemorySyncServer();
    now = DateTime.utc(2026, 9, 25, 10);
  });

  test('two devices selling offline end up with the same data', () async {
    final pc = device('pc'), phone = device('phone');
    pc.write('products', 'p1', {'id': 'p1', 'price': 4500});
    pc.write('sales', 's1', {'id': 's1', 'total': 4500});
    phone.write('sales', 's2', {'id': 's2', 'total': 9000});

    await engine(pc).sync();
    await engine(phone).sync();
    await engine(pc).sync();

    expect(pc.tables, phone.tables);
    expect(pc.tables['sales']!.keys, unorderedEquals(['s1', 's2']));
    expect(pc.outboxLength + phone.outboxLength, 0);
  });

  test('an interrupted push is resent later and stored once', () async {
    final pc = device('pc'), phone = device('phone');
    pc.write('sales', 's1', {'id': 's1'});
    server.failNext = true;
    await expectLater(engine(pc).sync(), throwsA(isA<SyncNetworkException>()));
    expect(pc.outboxLength, 1); // nothing lost
    await engine(pc).sync();
    await engine(pc).sync(); // again: harmless
    final r = await engine(phone).sync();
    expect(r.pulled, 1);
    expect(phone.tables['sales']!.keys, ['s1']);
  });

  test('a later edit wins on every device, whichever syncs first', () async {
    final pc = device('pc'), phone = device('phone');
    pc.write('products', 'p1', {'price': 1});
    await engine(pc).sync();
    await engine(phone).sync();

    now = now.add(const Duration(minutes: 1));
    phone.write('products', 'p1', {'price': 3}); // 10:01 on the phone
    now = now.subtract(const Duration(seconds: 30));
    pc.write('products', 'p1', {'price': 2}); // 10:00:30 on the PC, offline

    await engine(phone).sync(); // phone's newer edit reaches the server first
    await engine(pc).sync(); // PC's older edit loses; PC takes the phone's
    await engine(phone).sync();
    expect(pc.tables['products']!['p1'], {'price': 3});
    expect(phone.tables['products']!['p1'], {'price': 3});
  });

  test('a pulled older value never overwrites a newer local edit not yet pushed', () async {
    final pc = device('pc'), phone = device('phone');
    phone.write('customers', 'c1', {'phone': 'old'});
    await engine(phone).sync();
    now = now.add(const Duration(minutes: 5));
    pc.write('customers', 'c1', {'phone': 'new'}); // local, newer
    // Pull only (simulates a pull landing before this device pushed).
    final page = await server.transportFor('pc').pull(after: 0, limit: 10);
    await pc.apply(page.changes, page.cursor);
    expect(pc.tables['customers']!['c1'], {'phone': 'new'});
  });

  test('deletions of master data reach the other devices', () async {
    final pc = device('pc'), phone = device('phone');
    pc.write('product_barcodes', '622', {'product_id': 'p1'});
    await engine(pc).sync();
    await engine(phone).sync();
    expect(phone.tables['product_barcodes']!.keys, ['622']);
    now = now.add(const Duration(minutes: 1));
    pc.delete('product_barcodes', '622');
    await engine(pc).sync();
    await engine(phone).sync();
    expect(phone.tables['product_barcodes'], isEmpty);
  });

  test('many edits of one row are pushed once, as the latest state', () async {
    final pc = device('pc');
    for (var i = 0; i < 5; i++) {
      now = now.add(const Duration(seconds: 1));
      pc.write('products', 'p1', {'price': i});
    }
    final r = await engine(pc).sync();
    expect(r.pushed, 1);
    expect(pc.outboxLength, 0);
  });

  test('a new device downloads everything in pages, with progress', () async {
    final pc = device('pc'), phone = device('phone');
    for (var i = 0; i < 25; i++) {
      pc.write('stock_events', 'e$i', {'n': i});
    }
    await engine(pc, batch: 7).sync();
    final progress = <SyncProgress>[];
    final r = await engine(phone, limit: 10).sync(onProgress: progress.add);
    expect(r.pulled, 25);
    expect(phone.tables['stock_events']!.length, 25);
    expect(progress.map((p) => p.cursor).toList(), [10, 20, 25]);
    expect(progress.last.latest, 25);
  });

  test('changes the server refuses are dropped from the outbox, not retried forever', () async {
    final pc = device('pc');
    pc.write('not_a_table', 'x', {'a': 1});
    pc.delete('sales', 's1'); // ledgers can't be deleted
    final r = await engine(pc).sync();
    expect((r.rejected, pc.outboxLength), (2, 0));
  });

  test('newerThan: time first, device id breaks ties', () {
    final t = DateTime.utc(2026);
    expect(newerThan(t.add(const Duration(seconds: 1)), 'a', t, 'z'), isTrue);
    expect(newerThan(t, 'b', t, 'a'), isTrue);
    expect(newerThan(t, 'a', t, 'a'), isFalse);
  });
}
