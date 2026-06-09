import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';
import '../providers/product_provider.dart';
import '../providers/invoice_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cài đặt & Sao lưu'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Sao lưu dữ liệu (Chia sẻ máy)',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Để dùng chung dữ liệu với máy khác, hãy chọn "Xuất dữ liệu" rồi gửi file đó qua Zalo. Ở máy kia, chọn "Nhập dữ liệu" và mở file vừa nhận.',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            icon: const Icon(Icons.upload_file),
            label: const Text('Xuất dữ liệu kho hàng (.mana)'),
            onPressed: () => _exportData(context, ref),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            icon: const Icon(Icons.download),
            label: const Text('Nhập dữ liệu từ file'),
            onPressed: () => _importData(context, ref),
          ),
          const Divider(height: 40),
          const Text(
            'Xuất Excel',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Tính năng xuất danh sách sản phẩm ra Excel để xem trên máy tính (sắp ra mắt cùng giao diện mới).',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Future<void> _exportData(BuildContext context, WidgetRef ref) async {
    try {
      final db = ref.read(databaseHelperProvider);
      final dbPath = await db.exportDatabase();
      
      // We copy it to a new file named backup.mana so the user recognizes it
      final backupDir = await Directory.systemTemp.createTemp();
      final backupFile = File('${backupDir.path}/manastore_backup.mana');
      await File(dbPath).copy(backupFile.path);

      await Share.shareXFiles([XFile(backupFile.path)], text: 'Dữ liệu cửa hàng Mana Store');
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
    }
  }

  Future<void> _importData(BuildContext context, WidgetRef ref) async {
    try {
      final result = await FilePicker.platform.pickFiles();
      if (result != null && result.files.single.path != null) {
        final path = result.files.single.path!;
        
        final confirm = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Cảnh báo'),
            content: const Text('Việc nhập dữ liệu sẽ XOÁ toàn bộ dữ liệu hiện tại trên máy này và thay bằng dữ liệu trong file. Bạn có chắc chắn không?'),
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
          await db.importDatabase(path);
          
          ref.invalidate(productListProvider);
          ref.invalidate(invoiceListProvider);
          ref.invalidate(todayRevenueProvider);
          ref.invalidate(todayInvoiceCountProvider);
          ref.invalidate(totalProductCountProvider);

          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Nhập dữ liệu thành công!')));
        }
      }
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
    }
  }
}
