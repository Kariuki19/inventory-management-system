import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'barcode_scanner_stub.dart'
    if (dart.library.io) 'barcode_scanner_mobile.dart' as scanner;

/// Provides a platform-appropriate way to obtain a barcode for a new item.
class BarcodeService {
  /// Returns a scanned or manually entered barcode, or `null` when cancelled.
  static Future<String?> getBarcodeValue(BuildContext context) async {
    if (kIsWeb) {
      return _showManualEntryDialog(context);
    }

    return _scanWithCamera(context);
  }

  static Future<String?> _showManualEntryDialog(BuildContext context) async {
    final controller = TextEditingController();

    final value = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Enter barcode'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Barcode or SKU',
            hintText: 'e.g. 1234567890123',
          ),
          textInputAction: TextInputAction.done,
          onSubmitted: (barcode) => Navigator.of(dialogContext).pop(barcode),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.of(dialogContext).pop(controller.text.trim()),
            child: const Text('Continue'),
          ),
        ],
      ),
    );

    controller.dispose();
    final barcode = value?.trim();
    return barcode == null || barcode.isEmpty ? null : barcode;
  }

  static Future<String?> _scanWithCamera(BuildContext context) async {
    // This method is reached only from the non-web branch in [getBarcodeValue].
    if (kIsWeb) return null;

    return scanner.scanBarcode(context);
  }
}
