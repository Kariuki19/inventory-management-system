import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import '../services/report_service.dart';
import '../../inventory/services/inventory_service.dart';

class ReportDownloadSheet {
  static Future<void> show(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Download report',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              const Text(
                  'Generate a live inventory report from your current data.'),
              const SizedBox(height: 16),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.picture_as_pdf_outlined),
                title: const Text('Download as PDF'),
                onTap: () => _download(context, sheetContext, ReportFormat.pdf),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.table_view_outlined),
                title: const Text('Download as Excel'),
                onTap: () =>
                    _download(context, sheetContext, ReportFormat.excel),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Future<void> _download(
    BuildContext context,
    BuildContext sheetContext,
    ReportFormat format,
  ) async {
    Navigator.of(sheetContext).pop();
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        content: Row(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(width: 20),
            Expanded(
              child: Text(
                'Generating ${format == ReportFormat.pdf ? 'PDF' : 'Excel'} report…',
              ),
            ),
          ],
        ),
      ),
    );

    try {
      final isDemoMode = InventoryService.isDemoMode;
      final download = await ReportService.generateAndDownloadReport(
        format,
        isDemoMode: isDemoMode,
      );
      if (context.mounted) {
        Navigator.of(context, rootNavigator: true).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(kIsWeb
                ? 'Report downloaded to browser downloads'
                : 'Report saved to ${download.path}'),
          ),
        );
      }
    } catch (error) {
      if (context.mounted) {
        Navigator.of(context, rootNavigator: true).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not generate report: $error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
