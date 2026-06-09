import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/product_provider.dart';
import 'product_form_screen.dart';

class ProductListScreen extends ConsumerWidget {
  const ProductListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(productListProvider);
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kho hàng'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            tooltip: 'Thêm sản phẩm',
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProductFormScreen()),
              );
              if (result == true) ref.invalidate(productListProvider);
            },
          ),
        ],
      ),
      body: productsAsync.when(
        data: (products) {
          if (products.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: cs.surfaceContainerHighest.withValues(alpha: 0.3),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.inventory_2_outlined, size: 56, color: cs.onSurfaceVariant.withValues(alpha: 0.4)),
                  ),
                  const SizedBox(height: 20),
                  Text('Chưa có sản phẩm nào', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: cs.onSurface.withValues(alpha: 0.7))),
                  const SizedBox(height: 6),
                  const Text('Bấm + để thêm sản phẩm đầu tiên'),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            itemCount: products.length,
            itemBuilder: (_, i) {
              final product = products[i];
              final inStock = product.stock > 0;

              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => ProductFormScreen(product: product)),
                    );
                    if (result == true) ref.invalidate(productListProvider);
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    child: Row(
                      children: [
                        _ProductIcon(cs: cs, inStock: inStock),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      product.name,
                                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      NumberFormat('#,### đ').format(product.price),
                                      style: TextStyle(
                                        fontWeight: FontWeight.w800,
                                        color: cs.primary,
                                        fontSize: 16,
                                      ),
                                      textAlign: TextAlign.end,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Icon(Icons.qr_code_rounded, size: 15, color: cs.onSurfaceVariant.withValues(alpha: 0.6)),
                                  const SizedBox(width: 6),
                                  Flexible(
                                    child: Text(
                                      product.barcode,
                                      style: TextStyle(fontSize: 13, color: cs.onSurfaceVariant),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const Spacer(),
                                  _StockBadge(cs: cs, inStock: inStock, stock: product.stock),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(Icons.edit_outlined, size: 18, color: cs.onSurfaceVariant.withValues(alpha: 0.25)),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
        error: (e, _) => Center(child: Text('Lỗi: $e')),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}

class _ProductIcon extends StatelessWidget {
  final ColorScheme cs;
  final bool inStock;

  const _ProductIcon({required this.cs, required this.inStock});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: inStock ? cs.primaryContainer : cs.errorContainer,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Center(
        child: Icon(
          Icons.inventory_2_rounded,
          size: 24,
          color: inStock ? cs.onPrimaryContainer : cs.onErrorContainer,
        ),
      ),
    );
  }
}

class _StockBadge extends StatelessWidget {
  final ColorScheme cs;
  final bool inStock;
  final int stock;

  const _StockBadge({required this.cs, required this.inStock, required this.stock});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: (inStock ? cs.primary : cs.error).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            inStock ? Icons.check_circle_rounded : Icons.remove_circle_outline_rounded,
            size: 12,
            color: inStock ? cs.primary : cs.error,
          ),
          const SizedBox(width: 4),
          Text(
            inStock ? 'Còn $stock' : 'Hết hàng',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: inStock ? cs.primary : cs.error,
            ),
          ),
        ],
      ),
    );
  }
}
