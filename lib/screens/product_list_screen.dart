import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/product.dart';
import '../providers/product_provider.dart';
import 'product_form_screen.dart';

class ProductListScreen extends ConsumerStatefulWidget {
  const ProductListScreen({super.key});

  @override
  ConsumerState<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends ConsumerState<ProductListScreen> {
  int _filterMode = 0;
  bool _sortNewestFirst = true;

  List<Product> _filterProducts(List<Product> products) {
    switch (_filterMode) {
      case 1:
        return products.where((p) => p.stock > 0).toList();
      case 2:
        return products.where((p) => p.stock <= 5 && p.stock > 0).toList();
      case 3:
        return products.where((p) => p.stock <= 0).toList();
      default:
        return products;
    }
  }

  List<Product> _sortProducts(List<Product> products) {
    products.sort((a, b) {
      final aTime = a.updatedAt ?? a.createdAt ?? DateTime(2000);
      final bTime = b.updatedAt ?? b.createdAt ?? DateTime(2000);
      return _sortNewestFirst ? bTime.compareTo(aTime) : aTime.compareTo(bTime);
    });
    return products;
  }

  Future<void> _quickAddStock(Product product) async {
    final controller = TextEditingController();
    final result = await showDialog<int>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Nhập thêm: ${product.name}'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Số lượng thêm', prefixIcon: Icon(Icons.add)),
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
          ElevatedButton(
            onPressed: () {
              final qty = int.tryParse(controller.text.trim());
              if (qty == null || qty <= 0) return;
              Navigator.pop(ctx, qty);
            },
            child: const Text('Nhập hàng'),
          ),
        ],
      ),
    );
    if (result == null || result <= 0) return;

    final db = ref.read(databaseHelperProvider);
    final pid = product.id;
    if (pid == null) return;
    await db.updateProduct(product.copyWith(stock: product.stock + result, updatedAt: DateTime.now()));
    ref.invalidate(productListProvider);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Đã nhập thêm $result ${product.name}'),
      backgroundColor: Colors.green,
      duration: const Duration(seconds: 2),
    ));
  }

  Widget _buildFilterChip(String label, int mode, int count) {
    final selected = _filterMode == mode;
    final cs = Theme.of(context).colorScheme;
    return FilterChip(
      label: Text('$label ($count)'),
      selected: selected,
      onSelected: (_) => setState(() => _filterMode = mode),
      showCheckmark: false,
      selectedColor: cs.primaryContainer,
      labelStyle: TextStyle(
        fontSize: 13,
        fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
        color: selected ? cs.onPrimaryContainer : cs.onSurfaceVariant,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(productListProvider);
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kho hàng'),
        actions: [
          IconButton(
            icon: Icon(_sortNewestFirst ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded),
            tooltip: _sortNewestFirst ? 'Mới nhất' : 'Cũ nhất',
            onPressed: () => setState(() => _sortNewestFirst = !_sortNewestFirst),
          ),
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
          final filtered = _sortProducts(_filterProducts(products));

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

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip('Tất cả', 0, products.length),
                      const SizedBox(width: 8),
                      _buildFilterChip('Còn hàng', 1, products.where((p) => p.stock > 0).length),
                      const SizedBox(width: 8),
                      _buildFilterChip('Sắp hết', 2, products.where((p) => p.stock <= 5 && p.stock > 0).length),
                      const SizedBox(width: 8),
                      _buildFilterChip('Hết hàng', 3, products.where((p) => p.stock <= 0).length),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: filtered.isEmpty
                    ? Center(
                        child: Text(
                          _filterMode == 3 ? 'Không có sản phẩm hết hàng' : 'Không có sản phẩm phù hợp',
                          style: TextStyle(color: cs.onSurfaceVariant),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                        itemCount: filtered.length,
                        itemBuilder: (_, i) {
                          final product = filtered[i];
                          final inStock = product.stock > 0;

                          return Dismissible(
                            key: ValueKey(product.id),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 24),
                              decoration: BoxDecoration(
                                color: cs.error,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Icon(Icons.delete_outline_rounded, color: cs.onError, size: 24),
                            ),
                            confirmDismiss: (_) async {
                              return await showDialog<bool>(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: const Text('Xóa sản phẩm'),
                                  content: Text('Xóa "${product.name}"?\nHành động này không thể hoàn tác.'),
                                  actions: [
                                    TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Hủy')),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(backgroundColor: cs.error),
                                      onPressed: () => Navigator.pop(ctx, true),
                                      child: Text('Xóa', style: TextStyle(color: cs.onError)),
                                    ),
                                  ],
                                ),
                              );
                            },
                            onDismissed: (_) async {
                              final productId = product.id;
                              if (productId == null) return;
                              final db = ref.read(databaseHelperProvider);
                              try {
                                await db.deleteProduct(productId);
                                ref.invalidate(productListProvider);
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                    content: Text('Đã xóa "${product.name}"'),
                                    duration: const Duration(seconds: 2),
                                  ));
                                }
                              } catch (e) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                    content: Text('Không thể xóa: sản phẩm đã có trong hóa đơn'),
                                    backgroundColor: cs.error,
                                  ));
                                }
                                ref.invalidate(productListProvider);
                              }
                            },
                            child: Card(
                              margin: const EdgeInsets.only(bottom: 10),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                                side: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.5)),
                              ),
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
                                                const SizedBox(width: 4),
                                                GestureDetector(
                                                  onTap: () => _quickAddStock(product),
                                                  child: Container(
                                                    padding: const EdgeInsets.all(4),
                                                    decoration: BoxDecoration(
                                                      color: cs.primary.withValues(alpha: 0.1),
                                                      borderRadius: BorderRadius.circular(6),
                                                    ),
                                                    child: Icon(Icons.add, size: 16, color: cs.primary),
                                                  ),
                                                ),
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
                            ),
                          );
                        },
                      ),
              ),
            ],
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