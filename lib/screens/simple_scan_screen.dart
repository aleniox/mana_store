import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:audioplayers/audioplayers.dart';
import '../widgets/scanner_overlay.dart';

class SimpleScanScreen extends StatefulWidget {
  const SimpleScanScreen({super.key});

  @override
  State<SimpleScanScreen> createState() => _SimpleScanScreenState();
}

class _SimpleScanScreenState extends State<SimpleScanScreen> {
  late final MobileScannerController _controller;
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _processing = false;
  Timer? _stabilizeTimer;

  @override
  void initState() {
    super.initState();
    _controller = MobileScannerController(detectionSpeed: DetectionSpeed.normal);
  }

  @override
  void dispose() {
    _stabilizeTimer?.cancel();
    _controller.dispose();
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

    _stabilizeTimer?.cancel();
    _stabilizeTimer = Timer(const Duration(milliseconds: 350), () {
      _processing = true;
      _stabilizeTimer = null;
      HapticFeedback.heavyImpact();
      Navigator.pop(context, barcode);
      _playSuccessSound().catchError((_) {});
    });
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
              Positioned(
                top: 16,
                right: 16,
                child: GestureDetector(
                  onTap: () => _controller.switchCamera(),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.black38,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: const Icon(Icons.flip_camera_android, color: Colors.white, size: 24),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
