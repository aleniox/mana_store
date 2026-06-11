import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:excel/excel.dart' hide Border;
import 'package:path_provider/path_provider.dart';
import '../providers/product_provider.dart';
import '../providers/invoice_provider.dart';
import '../providers/locale_provider.dart';
import '../l10n/app_localizations.dart';
import '../models/product.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    final locale = ref.watch(localeProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settings)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // === Sao lưu Database ===
          _buildSectionHeader(context, l10n.backupRestore),
          const SizedBox(height: 4),
          Text(
            l10n.databaseBackupDesc,
            style: TextStyle(fontSize: 13, color: cs.onSurfaceVariant),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  icon: Icons.upload_file,
                  label: l10n.exportDatabase,
                  onPressed: () => _exportDatabase(context, ref),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionButton(
                  icon: Icons.download,
                  label: l10n.importDatabase,
                  isOutlined: true,
                  onPressed: () => _importDatabase(context, ref),
                ),
              ),
            ],
          ),
          const Divider(height: 40),

          // === Xuất/Nhập kho hàng ===
          _buildSectionHeader(context, l10n.syncProducts),
          const SizedBox(height: 4),
          Text(
            l10n.productSyncDesc,
            style: TextStyle(fontSize: 13, color: cs.onSurfaceVariant),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  icon: Icons.file_upload_outlined,
                  label: l10n.exportProducts,
                  onPressed: () => _exportProducts(context, ref),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionButton(
                  icon: Icons.file_download_outlined,
                  label: l10n.importProducts,
                  isOutlined: true,
                  onPressed: () => _importProducts(context, ref),
                ),
              ),
            ],
          ),
          const Divider(height: 40),

          // === Ngôn ngữ ===
          _buildSectionHeader(context, l10n.language),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: cs.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.4)),
            ),
            child: Column(
              children: [
                _LangOption(
                  icon: '🇻🇳',
                  title: 'Tiếng Việt',
                  subtitle: 'Ngôn ngữ mặc định',
                  isSelected: locale == const Locale('vi'),
                  onTap: () => ref.read(localeProvider.notifier).state = const Locale('vi'),
                  isTop: true,
                ),
                Divider(height: 0, indent: 72, endIndent: 16, color: cs.outlineVariant.withValues(alpha: 0.3)),
                _LangOption(
                  icon: '🇺🇸',
                  title: 'English',
                  subtitle: '',
                  isSelected: locale == const Locale('en'),
                  onTap: () => ref.read(localeProvider.notifier).state = const Locale('en'),
                  isTop: false,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Text(
      title,
      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Theme.of(context).colorScheme.onSurface),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    bool isOutlined = false,
  }) {
    if (isOutlined) {
      return OutlinedButton.icon(
        icon: Icon(icon, size: 18),
        label: Text(label, style: const TextStyle(fontSize: 13)),
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      );
    }
    return FilledButton.icon(
      icon: Icon(icon, size: 18),
      label: Text(label, style: const TextStyle(fontSize: 13)),
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }

  // ============================================================
  //  Database backup / restore
  // ============================================================

  Future<void> _exportDatabase(BuildContext context, WidgetRef ref) async {
    try {
      final db = ref.read(databaseHelperProvider);
      final dbPath = await db.exportDatabase();
      final backupDir = await Directory.systemTemp.createTemp();
      final backupFile = File('${backupDir.path}/manastore_backup.mana');
      await File(dbPath).copy(backupFile.path);
      await Share.shareXFiles([XFile(backupFile.path)], text: 'Dữ liệu Mana Store');
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
    }
  }

  Future<void> _importDatabase(BuildContext context, WidgetRef ref) async {
    try {
      final result = await FilePicker.platform.pickFiles();
      if (result == null || result.files.single.path == null) return;

      final confirm = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Cảnh báo'),
          content: const Text('Việc nhập dữ liệu sẽ XOÁ toàn bộ dữ liệu hiện tại và thay bằng dữ liệu trong file. Bạn có chắc chắn không?'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Hủy')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Chấp nhận', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );

      if (confirm == true) {
        final db = ref.read(databaseHelperProvider);
        await db.importDatabase(result.files.single.path!);
        _refreshAll(ref);
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Nhập dữ liệu thành công!')));
      }
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
    }
  }

  // ============================================================
  //  Product list export / import (Excel)
  // ============================================================

  Future<void> _exportProducts(BuildContext context, WidgetRef ref) async {
    try {
      final db = ref.read(databaseHelperProvider);
      final products = await db.getAllProducts();

      final excel = Excel.createExcel();
      final sheet = excel['Sản phẩm'];

      sheet.cell(CellIndex.indexByString('A1')).value = TextCellValue('Mã vạch');
      sheet.cell(CellIndex.indexByString('B1')).value = TextCellValue('Tên sản phẩm');
      sheet.cell(CellIndex.indexByString('C1')).value = TextCellValue('Giá');
      sheet.cell(CellIndex.indexByString('D1')).value = TextCellValue('Tồn kho');

      for (int i = 0; i < products.length; i++) {
        final p = products[i];
        final row = i + 2;
        sheet.cell(CellIndex.indexByString('A$row')).value = TextCellValue(p.barcode);
        sheet.cell(CellIndex.indexByString('B$row')).value = TextCellValue(p.name);
        sheet.cell(CellIndex.indexByString('C$row')).value = IntCellValue(p.price.toInt());
        sheet.cell(CellIndex.indexByString('D$row')).value = IntCellValue(p.stock);
      }

      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/products.xlsx');
      await file.writeAsBytes(excel.encode()!);

      HapticFeedback.mediumImpact();
      await Share.shareXFiles([XFile(file.path)], text: 'Danh sách sản phẩm');
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
    }
  }

  Future<void> _importProducts(BuildContext context, WidgetRef ref) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx'],
      );
      if (result == null || result.files.single.path == null) return;

      final bytes = await File(result.files.single.path!).readAsBytes();
      final excel = Excel.decodeBytes(bytes);
      final sheet = excel.sheets.values.firstOrNull;
      if (sheet == null) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('File Excel không có dữ liệu')));
        return;
      }

      int imported = 0;
      int updated = 0;
      final db = ref.read(databaseHelperProvider);

      for (int row = 1; row <= sheet.maxRows; row++) {
        final barcodeCell = sheet.cell(CellIndex.indexByString('A${row + 1}'));
        final nameCell = sheet.cell(CellIndex.indexByString('B${row + 1}'));
        if (barcodeCell.value == null || nameCell.value == null) continue;

        String? barcode, name;
        final bv = barcodeCell.value;
        final nv = nameCell.value;
        if (bv is TextCellValue) barcode = bv.value.toString().trim();
        if (nv is TextCellValue) name = nv.value.toString().trim();
        if (barcode == null || name == null || barcode.isEmpty || name.isEmpty) continue;

        final priceCell = sheet.cell(CellIndex.indexByString('C${row + 1}'));
        final stockCell = sheet.cell(CellIndex.indexByString('D${row + 1}'));
        double price = 0.0;
        int stock = 0;
        final pv = priceCell.value;
        final sv = stockCell.value;
        if (pv is IntCellValue) price = pv.value.toDouble();
        if (pv is DoubleCellValue) price = pv.value;
        if (sv is IntCellValue) stock = sv.value;

        final existing = await db.getProductByBarcode(barcode);
        if (existing != null) {
          await db.updateProduct(existing.copyWith(
            name: name,
            price: price,
            stock: stock,
          ));
          updated++;
        } else {
          await db.insertProduct(Product(
            barcode: barcode,
            name: name,
            price: price,
            stock: stock,
          ));
          imported++;
        }
      }

      _refreshAll(ref);

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Nhập thành công: $imported mới, $updated cập nhật'),
        backgroundColor: Colors.green,
      ));
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
    }
  }

  void _refreshAll(WidgetRef ref) {
    ref.invalidate(productListProvider);
    ref.invalidate(invoiceListProvider);
    ref.invalidate(todayRevenueProvider);
    ref.invalidate(todayInvoiceCountProvider);
    ref.invalidate(totalProductCountProvider);
    ref.invalidate(revenueByYearProvider);
  }
}

class _LangOption extends StatelessWidget {
  final String icon;
  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isTop;

  const _LangOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
    required this.isTop,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.vertical(
        top: isTop ? const Radius.circular(14) : Radius.zero,
        bottom: !isTop ? const Radius.circular(14) : Radius.zero,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Text(icon, style: const TextStyle(fontSize: 28)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: cs.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 13, color: cs.onSurfaceVariant),
                  ),
                ],
              ),
            ),
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? cs.primary : Colors.transparent,
                border: Border.all(
                  color: isSelected ? cs.primary : cs.outline,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Icon(Icons.check, size: 14, color: cs.onPrimary)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
