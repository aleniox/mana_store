import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/product.dart';
import '../providers/product_provider.dart';
import 'simple_scan_screen.dart';

class ProductFormScreen extends ConsumerStatefulWidget {
  final Product? product;
  const ProductFormScreen({super.key, this.product});

  @override
  ProductFormScreenState createState() => ProductFormScreenState();
}

class ProductFormScreenState extends ConsumerState<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _barcodeCtrl;
  late final TextEditingController _nameCtrl;
  late final TextEditingController _priceCtrl;
  late final TextEditingController _stockCtrl;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _barcodeCtrl = TextEditingController(text: widget.product?.barcode ?? '');
    _nameCtrl = TextEditingController(text: widget.product?.name ?? '');
    _priceCtrl = TextEditingController(
        text: widget.product?.price.toStringAsFixed(0) ?? '');
    _stockCtrl = TextEditingController(
        text: widget.product?.stock.toString() ?? '0');
  }

  @override
  void dispose() {
    _barcodeCtrl.dispose();
    _nameCtrl.dispose();
    _priceCtrl.dispose();
    _stockCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    final db = ref.read(databaseHelperProvider);
    final product = Product(
      id: widget.product?.id,
      barcode: _barcodeCtrl.text.trim(),
      name: _nameCtrl.text.trim(),
      price: double.parse(_priceCtrl.text.trim()),
      stock: int.parse(_stockCtrl.text.trim()),
    );

    try {
      if (widget.product != null) {
        await db.updateProduct(product);
      } else {
        await db.insertProduct(product);
      }
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: ${e.toString()}')),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.product != null;
    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'Sửa sản phẩm' : 'Thêm sản phẩm')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _barcodeCtrl,
              decoration: InputDecoration(
                labelText: 'Mã vạch',
                prefixIcon: const Icon(Icons.qr_code),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.camera_alt),
                  tooltip: 'Quét mã vạch',
                  onPressed: () async {
                    final code = await Navigator.push<String>(
                      context,
                      MaterialPageRoute(builder: (_) => const SimpleScanScreen()),
                    );
                    if (code != null && mounted) {
                      _barcodeCtrl.text = code;
                    }
                  },
                ),
              ),
              validator: (v) => v == null || v.trim().isEmpty ? 'Nhập mã vạch' : null,
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))],
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameCtrl,
              decoration: const InputDecoration(
                labelText: 'Tên sản phẩm',
                prefixIcon: Icon(Icons.label),
              ),
              validator: (v) => v == null || v.trim().isEmpty ? 'Nhập tên sản phẩm' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _priceCtrl,
              decoration: const InputDecoration(
                labelText: 'Giá (đ)',
                prefixIcon: Icon(Icons.monetization_on),
              ),
              keyboardType: TextInputType.number,
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Nhập giá';
                if (double.tryParse(v.trim()) == null) return 'Giá không hợp lệ';
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _stockCtrl,
              decoration: const InputDecoration(
                labelText: 'Tồn kho',
                prefixIcon: Icon(Icons.inventory),
              ),
              keyboardType: TextInputType.number,
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Nhập tồn kho';
                if (int.tryParse(v.trim()) == null) return 'Số không hợp lệ';
                return null;
              },
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isSaving ? null : _save,
              child: _isSaving
                  ? const SizedBox(
                      height: 20, width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : Text(isEdit ? 'Cập nhật' : 'Thêm sản phẩm'),
            ),
          ],
        ),
      ),
    );
  }
}
