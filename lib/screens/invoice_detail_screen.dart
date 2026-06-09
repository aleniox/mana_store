import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:excel/excel.dart';
import '../providers/invoice_provider.dart';

class InvoiceDetailScreen extends ConsumerWidget {
  final int invoiceId;
  const InvoiceDetailScreen({super.key, required this.invoiceId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(invoiceDetailProvider(invoiceId));
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('Hóa đơn #$invoiceId'),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf_rounded),
            tooltip: 'Xuất PDF',
            onPressed: () => _exportPdf(context, ref),
          ),
          IconButton(
            icon: const Icon(Icons.table_chart_outlined),
            tooltip: 'Xuất Excel',
            onPressed: () => _exportExcel(context, ref),
          ),
        ],
      ),
      body: detailAsync.when(
        data: (invoice) {
          if (invoice == null) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.search_off_rounded, size: 48, color: cs.onSurfaceVariant.withValues(alpha: 0.4)),
                  const SizedBox(height: 16),
                  const Text('Không tìm thấy hóa đơn'),
                ],
              ),
            );
          }

          final items = invoice.items ?? [];
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            children: [
              // Invoice header
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: cs.primaryContainer,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(Icons.receipt_rounded, color: cs.onPrimaryContainer, size: 32),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'HÓA ĐƠN #${invoice.id}',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: cs.onSurface,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: cs.surfaceContainerHighest.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          DateFormat('HH:mm · dd/MM/yyyy').format(invoice.createdAt),
                          style: TextStyle(color: cs.onSurfaceVariant, fontSize: 13),
                        ),
                      ),
                      const Divider(height: 32),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Tổng tiền:', style: TextStyle(fontSize: 16, color: cs.onSurfaceVariant)),
                          Text(
                            NumberFormat('#,### đ').format(invoice.total),
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: cs.primary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Items section
              Text(
                'Chi tiết sản phẩm',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: cs.onSurface),
              ),
              const SizedBox(height: 12),
              ...items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: cs.secondaryContainer,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(Icons.shopping_bag_rounded, color: cs.onSecondaryContainer, size: 22),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            item.productName,
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              NumberFormat('#,### đ').format(item.totalPrice),
                              style: TextStyle(fontWeight: FontWeight.w800, color: cs.primary, fontSize: 15),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${NumberFormat('#,###').format(item.unitPrice)} đ × ${item.quantity}',
                              style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              )),
            ],
          );
        },
        error: (e, _) => Center(child: Text('Lỗi: $e')),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }

  Future<void> _exportPdf(BuildContext context, WidgetRef ref) async {
    final invoice = ref.read(invoiceDetailProvider(invoiceId)).valueOrNull;
    if (invoice == null) return;

    HapticFeedback.mediumImpact();

    final pdf = pw.Document();
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a6,
        margin: const pw.EdgeInsets.all(16),
        build: (ctx) => [
          pw.Center(
            child: pw.Text(
              'HÓA ĐƠN #${invoice.id}',
              style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Center(
            child: pw.Text(DateFormat('HH:mm dd/MM/yyyy').format(invoice.createdAt)),
          ),
          pw.SizedBox(height: 16),
          pw.TableHelper.fromTextArray(
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11),
            cellStyle: pw.TextStyle(fontSize: 11),
            headers: ['SP', 'SL', 'ĐG', 'TT'],
            data: (invoice.items ?? []).map((item) => [
              item.productName,
              '${item.quantity}',
              NumberFormat('#,###').format(item.unitPrice),
              NumberFormat('#,###').format(item.totalPrice),
            ]).toList(),
          ),
          pw.Divider(),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('Tổng cộng:', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
              pw.Text(
                '${NumberFormat('#,###').format(invoice.total)} đ',
                style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );

    try {
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/invoice_${invoice.id}.pdf');
      final bytes = await pdf.save();
      await file.writeAsBytes(bytes);
      await Share.shareXFiles([XFile(file.path)], text: 'Hóa đơn #${invoice.id}');
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi xuất PDF'), backgroundColor: Theme.of(context).colorScheme.error),
      );
    }
  }

  Future<void> _exportExcel(BuildContext context, WidgetRef ref) async {
    final invoice = ref.read(invoiceDetailProvider(invoiceId)).valueOrNull;
    if (invoice == null) return;

    HapticFeedback.mediumImpact();

    try {
      final excel = Excel.createExcel();
      final sheet = excel['Hóa đơn'];

      sheet.cell(CellIndex.indexByString('A1')).value = TextCellValue('HÓA ĐƠN #${invoice.id}');
      sheet.cell(CellIndex.indexByString('A2')).value = TextCellValue(
        'Ngày: ${DateFormat('HH:mm dd/MM/yyyy').format(invoice.createdAt)}',
      );

      sheet.cell(CellIndex.indexByString('A4')).value = TextCellValue('Sản phẩm');
      sheet.cell(CellIndex.indexByString('B4')).value = TextCellValue('SL');
      sheet.cell(CellIndex.indexByString('C4')).value = TextCellValue('Đơn giá');
      sheet.cell(CellIndex.indexByString('D4')).value = TextCellValue('Thành tiền');

      int row = 5;
      for (final item in invoice.items ?? []) {
        sheet.cell(CellIndex.indexByString('A$row')).value = TextCellValue(item.productName);
        sheet.cell(CellIndex.indexByString('B$row')).value = IntCellValue(item.quantity);
        sheet.cell(CellIndex.indexByString('C$row')).value = IntCellValue(item.unitPrice.toInt());
        sheet.cell(CellIndex.indexByString('D$row')).value = IntCellValue(item.totalPrice.toInt());
        row++;
      }

      sheet.cell(CellIndex.indexByString('A$row')).value = TextCellValue('Tổng cộng:');
      sheet.cell(CellIndex.indexByString('D$row')).value = IntCellValue(invoice.total.toInt());

      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/invoice_${invoice.id}.xlsx');
      await file.writeAsBytes(excel.encode()!);
      await Share.shareXFiles([XFile(file.path)], text: 'Hóa đơn #${invoice.id}');
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi xuất Excel'), backgroundColor: Theme.of(context).colorScheme.error),
      );
    }
  }
}
