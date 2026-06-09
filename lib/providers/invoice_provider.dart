import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/invoice.dart';
import '../models/product.dart';
import 'product_provider.dart';

final revenueVisibleProvider = StateProvider<bool>((ref) => true);

final selectedYearProvider = StateProvider<int>((ref) => DateTime.now().year);

final invoiceListProvider = FutureProvider<List<Invoice>>((ref) async {
  final db = ref.read(databaseHelperProvider);
  return await db.getAllInvoices();
});

final invoiceDetailProvider = FutureProvider.family<Invoice?, int>((ref, id) async {
  final db = ref.read(databaseHelperProvider);
  return await db.getInvoiceWithItems(id);
});

final todayInvoiceCountProvider = FutureProvider<int>((ref) async {
  final db = ref.read(databaseHelperProvider);
  return await db.getTodayInvoiceCount();
});

final todayRevenueProvider = FutureProvider<double>((ref) async {
  final db = ref.read(databaseHelperProvider);
  return await db.getTodayRevenue();
});

final totalProductCountProvider = FutureProvider<int>((ref) async {
  final db = ref.read(databaseHelperProvider);
  return await db.getProductCount();
});

final revenueByMonthProvider = FutureProvider.family<List<Map<String, dynamic>>, int>((ref, year) async {
  final db = ref.read(databaseHelperProvider);
  return await db.getRevenueByMonth(year);
});

final revenueByYearProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final db = ref.read(databaseHelperProvider);
  return await db.getRevenueByYear();
});

class CartNotifier extends StateNotifier<List<CartItem>> {
  CartNotifier() : super([]);

  void addItem(ProductWithQuantity item) {
    final index = state.indexWhere((e) => e.product.id == item.product.id);
    if (index >= 0) {
      final updated = [...state];
      updated[index] = CartItem(
        product: item.product,
        quantity: updated[index].quantity + item.quantity,
      );
      state = updated;
    } else {
      state = [...state, CartItem(product: item.product, quantity: item.quantity)];
    }
  }

  void removeItem(int productId) {
    state = state.where((e) => e.product.id != productId).toList();
  }

  void updateQuantity(int productId, int quantity) {
    state = state.map((e) {
      if (e.product.id == productId) {
        return CartItem(product: e.product, quantity: quantity);
      }
      return e;
    }).toList();
  }

  void clear() {
    state = [];
  }

  double get total => state.fold(0, (sum, e) => sum + e.totalPrice);
}

final cartProvider = StateNotifierProvider<CartNotifier, List<CartItem>>((ref) {
  return CartNotifier();
});

class ProductWithQuantity {
  final Product product;
  final int quantity;
  ProductWithQuantity({required this.product, this.quantity = 1});
}

class CartItem {
  final Product product;
  final int quantity;
  CartItem({required this.product, this.quantity = 1});

  double get totalPrice => product.price * quantity;
}
