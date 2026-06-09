import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/invoice.dart';
import '../models/invoice_item.dart';
import '../models/product.dart';
import '../providers/invoice_provider.dart';
import '../providers/product_provider.dart';
import 'scan_screen.dart';

class CreateInvoiceScreen extends ConsumerStatefulWidget {
  const CreateInvoiceScreen({super.key});

  @override
  ConsumerState<CreateInvoiceScreen> createState() => _CreateInvoiceScreenState();
}

class _CreateInvoiceScreenState extends ConsumerState<CreateInvoiceScreen> {
  final _searchCtrl = TextEditingController();
  final _searchFocus = FocusNode();
  List<Product> _searchResults = [];

  @override
  void initState() {
    super.initState();
    _searchCtrl.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final q = _searchCtrl.text.trim();
    if (q.isEmpty) {
      setState(() => _searchResults = []);
      return;
    }
    ref.read(databaseHelperProvider).searchProducts(q).then((r) {
      if (mounted) setState(() => _searchResults = r);
    });
  }

  void _addToCart(Product product) {
    ref.read(cartProvider.notifier).addItem(ProductWithQuantity(product: product));
    _searchCtrl.clear();
    _searchFocus.unfocus();
    setState(() => _searchResults = []);
    HapticFeedback.lightImpact();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Theme.of(context).colorScheme.onPrimary, size: 18),
              const SizedBox(width: 8),
              Text('Đã thêm ${product.name}'),
            ],
          ),
          duration: const Duration(milliseconds: 900),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = ref.watch(cartProvider);
    final notifier = ref.read(cartProvider.notifier);
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        title: const Text('Bán hàng'),
        actions: [
          if (cart.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep_rounded),
              tooltip: 'Xóa giỏ hàng',
              onPressed: () => _confirmClear(context, notifier),
            ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(cs),
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            child: _searchResults.isNotEmpty
                ? _buildSearchResults(cs)
                : const SizedBox.shrink(),
          ),
          Expanded(
            child: cart.isEmpty
                ? _buildEmptyState(cs)
                : _buildCartList(cart, cs),
          ),
          if (cart.isNotEmpty)
            _buildBottomBar(cart, notifier, cs),
        ],
      ),
    );
  }

  Widget _buildSearchBar(ColorScheme cs) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchCtrl,
              focusNode: _searchFocus,
              style: const TextStyle(fontSize: 15),
              decoration: InputDecoration(
                hintText: 'Tìm kiếm sản phẩm...',
                prefixIcon: const Icon(Icons.search_rounded, size: 22),
                suffixIcon: _searchCtrl.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded, size: 20),
                        onPressed: () {
                          _searchCtrl.clear();
                          _searchFocus.unfocus();
                        },
                      )
                    : null,
              ),
              textInputAction: TextInputAction.search,
            ),
          ),
          const SizedBox(width: 10),
          Material(
            color: cs.primary,
            borderRadius: BorderRadius.circular(14),
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () {
                HapticFeedback.mediumImpact();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ScanScreen(
                      onScanned: (product) {
                        ref.read(cartProvider.notifier).addItem(
                          ProductWithQuantity(product: product),
                        );
                      },
                    ),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(14),
                child: Icon(Icons.qr_code_scanner_rounded, color: cs.onPrimary, size: 24),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults(ColorScheme cs) {
    return Container(
      constraints: const BoxConstraints(maxHeight: 280),
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.6)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: _searchResults.isEmpty
          ? Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search_off_rounded, color: cs.onSurfaceVariant.withValues(alpha: 0.5), size: 20),
                  const SizedBox(width: 8),
                  Text('Không tìm thấy sản phẩm', style: TextStyle(color: cs.onSurfaceVariant)),
                ],
              ),
            )
          : ListView.separated(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              itemCount: _searchResults.length,
              separatorBuilder: (_, __) => Divider(indent: 56, endIndent: 16, color: cs.outlineVariant.withValues(alpha: 0.3)),
              itemBuilder: (_, i) {
                final p = _searchResults[i];
                return InkWell(
                  borderRadius: BorderRadius.vertical(
                    top: const Radius.circular(16),
                    bottom: const Radius.circular(16),
                  ),
                  onTap: () => _addToCart(p),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: cs.primaryContainer,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(Icons.inventory_2_rounded, color: cs.onPrimaryContainer, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(p.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                              const SizedBox(height: 2),
                              Text('Tồn: ${p.stock}', style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant)),
                            ],
                          ),
                        ),
                        Flexible(
                          child: Text(
                            NumberFormat('#,### đ').format(p.price),
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: cs.primary,
                              fontSize: 14,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _buildEmptyState(ColorScheme cs) {
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
            child: Icon(Icons.receipt_long_outlined, size: 56, color: cs.onSurfaceVariant.withValues(alpha: 0.4)),
          ),
          const SizedBox(height: 20),
          Text(
            'Giỏ hàng trống',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: cs.onSurface.withValues(alpha: 0.7)),
          ),
          const SizedBox(height: 6),
          Text(
            'Tìm kiếm hoặc quét mã vạch\nđể thêm sản phẩm',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: cs.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  Widget _buildCartList(List<CartItem> cart, ColorScheme cs) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 100),
      itemCount: cart.length,
      itemBuilder: (_, i) {
        final item = cart[i];
        return Dismissible(
          key: ValueKey(item.product.id),
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
          onDismissed: (_) => ref.read(cartProvider.notifier).removeItem(item.product.id!),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: cs.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.4)),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: cs.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        '${i + 1}',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: cs.onPrimaryContainer,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.product.name,
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${NumberFormat('#,###').format(item.product.price)} đ',
                          style: TextStyle(fontSize: 13, color: cs.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          NumberFormat('#,### đ').format(item.totalPrice),
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: cs.primary,
                            fontSize: 14,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Container(
                          decoration: BoxDecoration(
                            color: cs.surfaceContainerHighest.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _QtyBtn(
                                icon: item.quantity > 1 ? Icons.remove_rounded : Icons.delete_outline_rounded,
                                color: item.quantity > 1 ? null : cs.error,
                                onTap: () {
                                  if (item.quantity > 1) {
                                    ref.read(cartProvider.notifier).updateQuantity(item.product.id!, item.quantity - 1);
                                  } else {
                                    ref.read(cartProvider.notifier).removeItem(item.product.id!);
                                  }
                                },
                              ),
                              SizedBox(
                                width: 30,
                                child: Text(
                                  '${item.quantity}',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                                ),
                              ),
                            _QtyBtn(
                              icon: Icons.add_rounded,
                              onTap: () {
                                ref.read(cartProvider.notifier).updateQuantity(item.product.id!, item.quantity + 1);
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomBar(List<CartItem> cart, CartNotifier notifier, ColorScheme cs) {
    final itemCount = cart.fold<int>(0, (s, e) => s + e.quantity);

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 16),
      decoration: BoxDecoration(
        color: cs.surface,
        border: Border(top: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.3))),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$itemCount sản phẩm',
                    style: TextStyle(fontSize: 13, color: cs.onSurfaceVariant),
                  ),
                  const SizedBox(height: 2),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: Text(
                      NumberFormat('#,### đ').format(notifier.total),
                      key: ValueKey(notifier.total),
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: cs.onSurface,
                        height: 1.1,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            FilledButton.icon(
              onPressed: () => _checkout(context, ref),
              icon: const Icon(Icons.payment_rounded, size: 20),
              label: const Text('Thanh toán'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                minimumSize: const Size(140, 52),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmClear(BuildContext context, CartNotifier notifier) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Xóa giỏ hàng?'),
        content: const Text('Toàn bộ sản phẩm trong giỏ sẽ bị xóa.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hủy'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Theme.of(ctx).colorScheme.error),
            onPressed: () {
              notifier.clear();
              Navigator.pop(ctx);
            },
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }

  Future<void> _checkout(BuildContext context, WidgetRef ref) async {
    final cart = ref.read(cartProvider);
    if (cart.isEmpty) return;
    final notifier = ref.read(cartProvider.notifier);
    final total = notifier.total;
    final itemCount = cart.fold<int>(0, (s, e) => s + e.quantity);

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Xác nhận thanh toán'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(ctx).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Text(
                    '$itemCount sản phẩm · ${cart.length} loại',
                    style: TextStyle(color: Theme.of(ctx).colorScheme.onPrimaryContainer),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    NumberFormat('#,### đ').format(total),
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: Theme.of(ctx).colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Xác nhận'),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    final db = ref.read(databaseHelperProvider);
    final items = cart.map((e) => InvoiceItem(
      invoiceId: 0,
      productId: e.product.id!,
      productName: e.product.name,
      quantity: e.quantity,
      unitPrice: e.product.price,
    )).toList();

    try {
      await db.insertInvoice(Invoice(total: total), items);
      if (!mounted) return;
      notifier.clear();
      ref.invalidate(invoiceListProvider);
      ref.invalidate(todayRevenueProvider);
      ref.invalidate(todayInvoiceCountProvider);
      HapticFeedback.heavyImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Text('Thanh toán thành công!'),
            ],
          ),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
      );
      if (Navigator.canPop(context)) Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: $e'), backgroundColor: Theme.of(context).colorScheme.error),
      );
    }
  }
}

class _QtyBtn extends StatelessWidget {
  final IconData icon;
  final Color? color;
  final VoidCallback onTap;

  const _QtyBtn({required this.icon, this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Icon(icon, size: 18, color: color),
      ),
    );
  }
}
