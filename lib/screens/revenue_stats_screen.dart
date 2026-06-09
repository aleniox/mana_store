import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/invoice_provider.dart';

class RevenueStatsScreen extends ConsumerWidget {
  const RevenueStatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final selectedYear = ref.watch(selectedYearProvider);
    final revenueVisible = ref.watch(revenueVisibleProvider);
    final yearDataAsync = ref.watch(revenueByYearProvider);
    final monthDataAsync = ref.watch(revenueByMonthProvider(selectedYear));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Thống kê doanh thu'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () {
              ref.invalidate(revenueByYearProvider);
              ref.invalidate(revenueByMonthProvider(selectedYear));
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        children: [
          // Year selector
          Row(
            children: [
              Icon(Icons.calendar_month_rounded, size: 18, color: cs.primary),
              const SizedBox(width: 8),
              Text('Chọn năm:', style: TextStyle(color: cs.onSurfaceVariant)),
              const SizedBox(width: 12),
              DropdownButton<int>(
                value: selectedYear,
                underline: const SizedBox(),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: cs.onSurface,
                ),
                items: List.generate(
                  DateTime.now().year - 2023 + 1,
                  (i) => DropdownMenuItem(
                    value: 2023 + i,
                    child: Text('${2023 + i}'),
                  ),
                ),
                onChanged: (v) {
                  if (v != null) ref.read(selectedYearProvider.notifier).state = v;
                },
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Year total card
          monthDataAsync.when(
            data: (months) {
              final total = months.fold<double>(0, (s, m) => s + (m['revenue'] as num).toDouble());
              final count = months.fold<int>(0, (s, m) => s + (m['count'] as int));
              return _buildYearTotal(cs, selectedYear, revenueVisible, total, count);
            },
            error: (_, __) => const SizedBox(),
            loading: () => const Card(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator())),
          ),
          const SizedBox(height: 20),

          // Monthly breakdown header
          Row(
            children: [
              Text('Doanh thu theo tháng',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: cs.onSurface)),
              const Spacer(),
              GestureDetector(
                onTap: () => ref.read(revenueVisibleProvider.notifier).update((s) => !s),
                child: Icon(
                  revenueVisible ? Icons.visibility_rounded : Icons.visibility_off_rounded,
                  size: 20, color: cs.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Monthly data
          monthDataAsync.when(
            data: (months) {
              if (months.isEmpty) {
                return _buildEmpty(cs, 'Chưa có dữ liệu năm $selectedYear');
              }
              return Column(
                children: months.map((m) => _buildMonthRow(cs, m, revenueVisible)).toList(),
              );
            },
            error: (_, __) => _buildEmpty(cs, 'Lỗi tải dữ liệu'),
            loading: () => const Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator())),
          ),
          const SizedBox(height: 28),

          // Yearly breakdown
          Text('Doanh thu theo năm',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: cs.onSurface)),
          const SizedBox(height: 12),
          yearDataAsync.when(
            data: (years) {
              if (years.isEmpty) return _buildEmpty(cs, 'Chưa có dữ liệu');
              return Column(
                children: years.map((y) => _buildYearRow(cs, y, revenueVisible)).toList(),
              );
            },
            error: (_, __) => _buildEmpty(cs, 'Lỗi tải dữ liệu'),
            loading: () => const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator())),
          ),
        ],
      ),
    );
  }

  Widget _buildYearTotal(ColorScheme cs, int year, bool visible, double total, int count) {
    return Container(
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
          Text('Tổng doanh thu $year',
            style: TextStyle(color: cs.onPrimary.withValues(alpha: 0.8), fontSize: 14)),
          const SizedBox(height: 8),
          Text(
            visible ? NumberFormat('#,### đ').format(total) : '*** *** đ',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: cs.onPrimary,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.receipt_long_rounded, size: 14, color: cs.onPrimary.withValues(alpha: 0.7)),
              const SizedBox(width: 4),
              Text('$count hóa đơn',
                style: TextStyle(color: cs.onPrimary.withValues(alpha: 0.7), fontSize: 13)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMonthRow(ColorScheme cs, Map<String, dynamic> m, bool visible) {
    final month = m['month'] as int;
    final revenue = (m['revenue'] as num).toDouble();
    final count = m['count'] as int;
    final monthNames = [
      'Tháng 1', 'Tháng 2', 'Tháng 3', 'Tháng 4', 'Tháng 5', 'Tháng 6',
      'Tháng 7', 'Tháng 8', 'Tháng 9', 'Tháng 10', 'Tháng 11', 'Tháng 12',
    ];

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.4)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: cs.primaryContainer.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text('$month',
                  style: TextStyle(fontWeight: FontWeight.w800, color: cs.onSurface, fontSize: 16)),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(monthNames[month - 1],
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                  const SizedBox(height: 2),
                  Text('$count hóa đơn',
                    style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant)),
                ],
              ),
            ),
            Text(
              visible ? NumberFormat('#,### đ').format(revenue) : '*** *** đ',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color: cs.primary,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildYearRow(ColorScheme cs, Map<String, dynamic> y, bool visible) {
    final year = y['year'] as int;
    final revenue = (y['revenue'] as num).toDouble();
    final count = y['count'] as int;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.4)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: cs.secondaryContainer.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text('${year % 100}',
                  style: TextStyle(fontWeight: FontWeight.w800, color: cs.onSurface, fontSize: 16)),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Năm $year',
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                  const SizedBox(height: 2),
                  Text('$count hóa đơn',
                    style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant)),
                ],
              ),
            ),
            Text(
              visible ? NumberFormat('#,### đ').format(revenue) : '*** *** đ',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color: cs.primary,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty(ColorScheme cs, String msg) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          children: [
            Icon(Icons.bar_chart_rounded, size: 48, color: cs.onSurfaceVariant.withValues(alpha: 0.3)),
            const SizedBox(height: 12),
            Text(msg, style: TextStyle(color: cs.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }
}
