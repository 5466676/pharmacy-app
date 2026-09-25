import 'package:doaya_core/doaya_core.dart';

final ids = UuidV7();
const device = 'dev-counter';
const employee = 'emp-1';
final t0 = DateTime.utc(2026, 9, 1, 9);

EventMeta meta({String? id, DateTime? at, String dev = device}) =>
    EventMeta(id: id ?? ids.generate(), deviceId: dev, employeeId: employee, occurredAt: at ?? t0);

StockEvent receive(String product, int qty, {DateTime? expiry, DateTime? at, String dev = device}) {
  final m = meta(at: at, dev: dev);
  return StockEvent(
    meta: m,
    type: StockEventType.received,
    productId: product,
    batchId: m.id,
    quantity: qty,
    expiry: expiry,
  );
}

StockEvent move(
  StockEventType type,
  String product,
  String batch,
  int qty, {
  String dev = device,
}) => StockEvent(
  meta: meta(dev: dev),
  type: type,
  productId: product,
  batchId: batch,
  quantity: qty,
);
