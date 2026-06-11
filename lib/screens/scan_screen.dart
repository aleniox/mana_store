import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:audioplayers/audioplayers.dart';
import '../providers/product_provider.dart';
import '../models/product.dart';
import '../widgets/scanner_overlay.dart';
import 'product_form_screen.dart';

class ScanScreen extends ConsumerStatefulWidget {
  final void Function(Product product) onScanned;
  const ScanScreen({super.key, required this.onScanned});

  @override
  ScanScreenState createState() => ScanScreenState();
}

class ScanScreenState extends ConsumerState<ScanScreen> {
  MobileScannerController? _controller;
  bool _processing = false;
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _controller = MobileScannerController(
      detectionSpeed: DetectionSpeed.noDuplicates,
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _playSuccessSound() async {
    await _audioPlayer.play(AssetSource('succes.mp3'));
  }

  void _onDetect(BarcodeCapture capture) {
    if (_processing) return;
    final barcode = capture.barcodes.firstOrNull?.rawValue;
    if (barcode == null || barcode.isEmpty) return;

    _processing = true;
    HapticFeedback.heavyImpact();
    _lookupProduct(barcode);
  }

  Future<void> _lookupProduct(String barcode) async {
    final db = ref.read(databaseHelperProvider);
    final product = await db.getProductByBarcode(barcode);

    if (!mounted) return;

    if (product != null) {
      widget.onScanned(product);
      _playSuccessSound();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đã thêm: ${product.name}'),
          duration: const Duration(milliseconds: 800),
          backgroundColor: Colors.green,
        ),
      );
      await Future.delayed(const Duration(milliseconds: 300));
      if (mounted) _processing = false;
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Không tìm thấy sản phẩm với mã $barcode'),
          duration: const Duration(seconds: 2),
          action: SnackBarAction(
            label: 'Thêm mới',
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => ProductFormScreen(
                    product: Product(
                      barcode: barcode,
                      name: '',
                      price: 0,
                      stock: 0,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      );
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) _processing = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quét mã vạch')),
      body: LayoutBuilder(
        builder: (_, constraints) {
          const scanAreaSize = 250.0;
          final scanRect = Rect.fromLTWH(
            (constraints.maxWidth - scanAreaSize) / 2,
            (constraints.maxHeight - scanAreaSize) / 2,
            scanAreaSize,
            scanAreaSize,
          );
          return Stack(
            children: [
              MobileScanner(
                controller: _controller,
                onDetect: _onDetect,
                scanWindow: scanRect,
              ),
              ScannerOverlay(scanRect: scanRect),
              const Positioned(
                bottom: 50,
                left: 0,
                right: 0,
                child: Text(
                  'Hướng camera vào mã vạch',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
