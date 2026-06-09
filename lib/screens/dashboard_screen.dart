import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/invoice_provider.dart';
import 'create_invoice_screen.dart';
import 'invoice_history_screen.dart';
import 'product_list_screen.dart';
import 'revenue_stats_screen.dart';
import 'settings_screen.dart';

class DashboardScreen extends ConsumerWidget {
  final VoidCallback? onNavigateToSale;

  const DashboardScreen({super.key, this.onNavigateToSale});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todayRevenue = ref.watch(todayRevenueProvider);
    final todayCount = ref.watch(todayInvoiceCountProvider);
    final productCount = ref.watch(totalProductCountProvider);
    final revenueVisible = ref.watch(revenueVisibleProvider);
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mana Store'),
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart_rounded),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const RevenueStatsScreen()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.inventory_2_outlined),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProductListScreen()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.settings_rounded),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
        children: [
          // Greeting
          Text(
            'Tổng quan hôm nay',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: cs.onSurface,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            DateFormat('EEEE, dd/MM/yyyy', 'vi').format(DateTime.now()),
            style: TextStyle(color: cs.onSurfaceVariant, fontSize: 14),
          ),
          const SizedBox(height: 20),

          // Revenue card
          todayRevenue.when(
            data: (rev) => Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [cs.primary, cs.primary.withValues(alpha: 0.8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: cs.primary.withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.trending_up_rounded, color: cs.onPrimary.withValues(alpha: 0.8), size: 22),
                      const SizedBox(width: 8),
                      Text(
                        'Doanh thu hôm nay',
                        style: TextStyle(color: cs.onPrimary.withValues(alpha: 0.8), fontSize: 14),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () => ref.read(revenueVisibleProvider.notifier).update((state) => !state),
                        child: Icon(
                          revenueVisible ? Icons.visibility_rounded : Icons.visibility_off_rounded,
                          color: cs.onPrimary.withValues(alpha: 0.7),
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    revenueVisible ? NumberFormat('#,### đ').format(rev) : '*** *** đ',
                    style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.w800,
                      color: cs.onPrimary,
                      height: 1.1,
                    ),
                  ),
                ],
              ),
            ),
            error: (_, __) => const Card(child: Padding(padding: EdgeInsets.all(24), child: Text('Lỗi tải dữ liệu'))),
            loading: () => const Card(child: Padding(padding: EdgeInsets.all(40), child: Center(child: CircularProgressIndicator()))),
          ),
          const SizedBox(height: 16),

          // Stat Row
          Row(
            children: [
              Expanded(
                child: todayCount.when(
                  data: (c) => _StatCard(
                    icon: Icons.receipt_long_rounded,
                    label: 'Hóa đơn',
                    value: '$c',
                  ),
                  error: (_, __) => const SizedBox(),
                  loading: () => const Card(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator())),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: productCount.when(
                  data: (c) => _StatCard(
                    icon: Icons.inventory_2_rounded,
                    label: 'Sản phẩm',
                    value: '$c',
                  ),
                  error: (_, __) => const SizedBox(),
                  loading: () => const Card(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator())),
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),

          // Section: Truy cập nhanh
          Text(
            'Truy cập nhanh',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: cs.onSurface),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _QuickActionCard(
                  icon: Icons.qr_code_scanner_rounded,
                  label: 'Bán hàng',
                  color: cs.primary,
                  onTap: () {
                    final cb = onNavigateToSale;
                    if (cb != null) {
                      cb();
                    } else {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateInvoiceScreen()));
                    }
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _QuickActionCard(
                  icon: Icons.history_rounded,
                  label: 'Lịch sử',
                  color: cs.tertiary,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const InvoiceHistoryScreen())),
                ),
              ),
              Expanded(
                child: _QuickActionCard(
                  icon: Icons.inventory_2_rounded,
                  label: 'Kho hàng',
                  color: cs.secondary,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProductListScreen())),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatCard({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          children: [
            Icon(icon, size: 28, color: cs.primary),
            const SizedBox(height: 10),
            Text(
              value,
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: cs.onSurface,
                height: 1,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(fontSize: 13, color: cs.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: cs.onSurfaceVariant),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
