import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database/database_helper.dart';
import '../models/product.dart';

final databaseHelperProvider = Provider<DatabaseHelper>((ref) {
  return DatabaseHelper();
});

final productListProvider = FutureProvider<List<Product>>((ref) async {
  final db = ref.read(databaseHelperProvider);
  return await db.getAllProducts();
});

final productSearchProvider = FutureProvider.family<List<Product>, String>((ref, query) async {
  final db = ref.read(databaseHelperProvider);
  if (query.isEmpty) return await db.getAllProducts();
  return await db.searchProducts(query);
});

final productByBarcodeProvider = FutureProvider.family<Product?, String>((ref, barcode) async {
  final db = ref.read(databaseHelperProvider);
  return await db.getProductByBarcode(barcode);
});
