import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'barcode_scanner_stub.dart'
    if (dart.library.html) 'barcode_scanner_web.dart'
    if (dart.library.io) 'barcode_scanner_mobile.dart' as scanner;

/// Provides a platform-appropriate way to obtain a barcode for a new item.
class BarcodeService {
  /// Returns a scanned or manually entered barcode, or `null` when cancelled.
  static Future<String?> getBarcodeValue(BuildContext context) async {
    if (kIsWeb) {
      return await _webScanOrManual(context);
    } else {
      return await _mobileScanOrManual(context);
    }
  }

  /// On web: request camera access and fall back to manual entry when needed.
  static Future<String?> _webScanOrManual(BuildContext context) async {
    try {
      final scanned = await scanner.scanBarcode(context);
      if (scanned != null && scanned.isNotEmpty) return scanned;
      return null;
    } catch (_) {
      return _showManualEntryDialog(context, title: 'Enter barcode');
    }
  }

  /// On mobile: attempt mobile_scanner, fall back to manual entry if denied.
  static Future<String?> _mobileScanOrManual(BuildContext context) async {
    try {
      final scanned = await scanner.scanBarcode(context);
      if (scanned != null && scanned.isNotEmpty) {
        return scanned;
      }
    } catch (_) {
      // Camera permission denied or scanner failed, fall back to manual entry
    }
    return _showManualEntryDialog(context, title: 'Enter barcode');
  }

  static Future<String?> _showManualEntryDialog(
    BuildContext context, {
    required String title,
  }) async {
    final controller = TextEditingController();

    final value = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(
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
}
