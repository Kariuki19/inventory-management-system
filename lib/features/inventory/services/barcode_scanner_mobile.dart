import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

/// Mobile-only camera scanner. This file is selected only on platforms with
/// `dart:io`, keeping `mobile_scanner` APIs out of web builds.
Future<String?> scanBarcode(BuildContext context) {
  return Navigator.of(context).push<String>(
    MaterialPageRoute(builder: (_) => const _BarcodeScannerScreen()),
  );
}

class _BarcodeScannerScreen extends StatefulWidget {
  const _BarcodeScannerScreen();

  @override
  State<_BarcodeScannerScreen> createState() => _BarcodeScannerScreenState();
}

class _BarcodeScannerScreenState extends State<_BarcodeScannerScreen> {
  final MobileScannerController _controller = MobileScannerController(facing: CameraFacing.back);
  bool _hasCapturedBarcode = false;
  bool _hasCameraError = false;

  void _onDetect(BarcodeCapture capture) {
    if (_hasCapturedBarcode) return;

    final barcode = capture.barcodes
        .map((value) => value.rawValue?.trim())
        .whereType<String>()
        .firstWhere((value) => value.isNotEmpty, orElse: () => '');
    if (barcode.isEmpty) return;

    _hasCapturedBarcode = true;
    Navigator.of(context).pop(barcode);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan barcode')),
      body: MobileScanner(
        controller: _controller,
        onDetect: _onDetect,
        errorBuilder: (context, error, child) {
          if (!_hasCameraError) {
            _hasCameraError = true;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) Navigator.of(context).pop();
            });
          }
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }
}
