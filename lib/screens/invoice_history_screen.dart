import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/invoice_provider.dart';
import 'invoice_detail_screen.dart';

class InvoiceHistoryScreen extends ConsumerWidget {
  const InvoiceHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final invoicesAsync = ref.watch(invoiceListProvider);
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Lịch sử hóa đơn')),
      body: invoicesAsync.when(
        data: (invoices) {
          if (invoices.isEmpty) {
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
                  Text('Chưa có hóa đơn nào', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: cs.onSurface.withValues(alpha: 0.7))),
                  const SizedBox(height: 6),
                  Text('Hóa đơn sẽ xuất hiện tại đây', style: TextStyle(color: cs.onSurfaceVariant)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            itemCount: invoices.length,
            itemBuilder: (_, i) {
              final inv = invoices[i];
              final time = DateFormat('HH:mm').format(inv.createdAt);
              final date = DateFormat('dd/MM/yyyy').format(inv.createdAt);

              return Card(
                color: Colors.white,
                elevation: 0,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.3)),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () {
                    final iid = inv.id;
                    if (iid == null) return;
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => InvoiceDetailScreen(invoiceId: iid)),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: cs.primaryContainer.withValues(alpha: 0.8),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Center(
                            child: Text(
                              '${inv.id}',
                              style: TextStyle(fontWeight: FontWeight.w800, color: cs.onSurface, fontSize: 18),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    date,
                                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                                  ),
                                  const Spacer(),
                                  Text(
                                    NumberFormat('#,### đ').format(inv.total),
                                    style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                      color: cs.primary,
                                      fontSize: 15,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(Icons.access_time_rounded, size: 14, color: cs.onSurfaceVariant.withValues(alpha: 0.8)),
                                  const SizedBox(width: 4),
                                  Text(time, style: TextStyle(fontSize: 13, color: cs.onSurfaceVariant, fontWeight: FontWeight.w600)),
                                  const Spacer(),
                                  Icon(Icons.shopping_bag_rounded, size: 14, color: cs.onSurfaceVariant.withValues(alpha: 0.8)),
                                  const SizedBox(width: 4),
                                  Text('${inv.items?.fold<int>(0, (sum, item) => sum + item.quantity) ?? 0} sản phẩm', style: TextStyle(fontSize: 13, color: cs.onSurfaceVariant, fontWeight: FontWeight.w600)),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(Icons.chevron_right_rounded, size: 22, color: cs.onSurfaceVariant.withValues(alpha: 0.3)),
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
