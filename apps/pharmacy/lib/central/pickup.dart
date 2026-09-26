import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A patient's case or order picked up at the counter: the POS opens with
/// these lines in the cart, and once the sale is done [onSold] marks it
/// picked up on Doaya online. The sale itself is a normal sale (who, which
/// device, the till), so stock and money stay right.
class PendingSale {
  const PendingSale({required this.lines, this.onSold});

  /// (product id, boxes).
  final List<(String, int)> lines;
  final Future<void> Function()? onSold;
}

class PendingSaleNotifier extends Notifier<PendingSale?> {
  @override
  PendingSale? build() => null;

  void set(PendingSale sale) => state = sale;

  /// The POS takes it once.
  PendingSale? take() {
    final s = state;
    state = null;
    return s;
  }
}

final pendingSaleProvider = NotifierProvider<PendingSaleNotifier, PendingSale?>(
  PendingSaleNotifier.new,
);
