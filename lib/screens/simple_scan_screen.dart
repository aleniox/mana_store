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

  @override
  void initState() {
    super.initState();
    _controller = MobileScannerController(detectionSpeed: DetectionSpeed.noDuplicates);
  }

  @override
  void dispose() {
    _controller.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _playSuccessSound() async {
    await _audioPlayer.play(AssetSource('succes.mp3'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quét mã vạch')),
      body: Stack(
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: (capture) async {
              final barcode = capture.barcodes.firstOrNull?.rawValue;
              if (barcode != null && barcode.isNotEmpty) {
                HapticFeedback.heavyImpact();
                await _playSuccessSound();
                if (!context.mounted) return;
                Navigator.pop(context, barcode);
              }
            },
          ),
          const ScannerOverlay(),
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
      ),
    );
  }
}
