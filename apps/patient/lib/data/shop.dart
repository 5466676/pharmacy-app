import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'models.dart';
import 'providers.dart';

/// One product in the cart, with the quantity the patient asks for.
class CartLine {
  const CartLine(this.item, this.quantity);

  final ShelfItem item;
  final int quantity;

  int get totalMinor => item.priceMinor * quantity;
}

/// The pickup cart for the chosen pharmacy (emptied when the pharmacy
/// changes). Quantities are a request: the pharmacist settles them.
class Cart extends Notifier<Map<String, CartLine>> {
  static const maxQuantity = 100;

  @override
  Map<String, CartLine> build() {
    ref.watch(authProvider.select((a) => a.patient?.pharmacy?.id));
    return const {};
  }

  void add(ShelfItem item, [int quantity = 1]) =>
      set(item, (state[item.productId]?.quantity ?? 0) + quantity);

  /// 0 removes the line.
  void set(ShelfItem item, int quantity) {
    final q = quantity.clamp(0, maxQuantity);
    state = {
      for (final e in state.entries)
        if (e.key != item.productId) e.key: e.value,
      if (q > 0) item.productId: CartLine(item, q),
    };
  }

  void clear() => state = const {};

  /// Sends the cart to the pharmacy and empties it.
  Future<PatientOrder> order({String? note}) async {
    final o = await ref.read(apiProvider).placeOrder({
      for (final l in state.values) l.item.productId: l.quantity,
    }, note: note == null || note.trim().isEmpty ? null : note.trim());
    clear();
    ref.invalidate(ordersProvider);
    return o;
  }
}

final cartProvider = NotifierProvider<Cart, Map<String, CartLine>>(Cart.new);

final cartCountProvider = Provider<int>(
  (ref) => ref.watch(cartProvider).values.fold(0, (n, l) => n + l.quantity),
);

final cartTotalProvider = Provider<int>(
  (ref) => ref.watch(cartProvider).values.fold(0, (n, l) => n + l.totalMinor),
);

/// A search of the chosen pharmacy's shelf ('' = everything, available first).
final shelfProvider = FutureProvider.family<List<ShelfItem>, String>((ref, query) {
  final pharmacy = ref.watch(authProvider.select((a) => a.patient?.pharmacy?.id));
  if (pharmacy == null) return const [];
  return ref.read(apiProvider).shelf(pharmacy, query: query, limit: 60);
});

final shelfItemProvider = FutureProvider.family<ShelfItem, String>((ref, productId) {
  final pharmacy = ref.watch(authProvider.select((a) => a.patient?.pharmacy?.id));
  return ref.read(apiProvider).shelfItem(pharmacy!, productId);
});

/// The patient's orders, newest first.
final ordersProvider = FutureProvider<List<PatientOrder>>((ref) {
  ref.watch(authProvider.select((a) => a.patient?.id));
  return ref.read(apiProvider).orders();
});

class OrderController extends AsyncNotifier<PatientOrder> {
  OrderController(this.id);
  final String id;

  @override
  Future<PatientOrder> build() => ref.read(apiProvider).order(id);

  Future<void> cancel() async {
    state = AsyncData(await ref.read(apiProvider).cancelOrder(id));
    ref.invalidate(ordersProvider);
  }
}

final orderProvider = AsyncNotifierProvider.family<OrderController, PatientOrder, String>(
  OrderController.new,
);
