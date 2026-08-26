import 'dart:io';
import 'dart:typed_data';

import 'package:excel/excel.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html show Blob, Url, AnchorElement;

import '../../auth/services/auth_service.dart';
import '../../inventory/models/inventory_item.dart';
import '../../inventory/services/inventory_service.dart';
import '../../predictions/models/stock_prediction.dart';
import '../../stock/models/stock_movement.dart';
import '../../../core/providers/demo_mode_provider.dart';

enum ReportFormat { pdf, excel }

class ReportDownload {
  final String path;
  final ReportFormat format;

  const ReportDownload({required this.path, required this.format});
}

/// Creates a point-in-time report from the active user's Firestore namespace.
///
/// All reads go through [InventoryService], which retains the existing admin,
/// staff, and shared demo data-isolation rules.
class ReportService {
  static const _periodLabel = 'All available inventory history';
  static final _dateTimeFormat = DateFormat('dd MMM yyyy, h:mm a');
  static final _fileDateFormat = DateFormat('yyyyMMdd_HHmmss');
  static final _currencyFormat = NumberFormat('#,##0.00');

  static Future<ReportDownload> generateAndOpen(ReportFormat format) async {
    final isDemoMode = InventoryService.isDemoMode;
    final report = await _loadReport();
    final bytes = switch (format) {
      ReportFormat.pdf => await _buildPdf(report, isDemoMode: isDemoMode),
      ReportFormat.excel => _buildExcel(report, isDemoMode: isDemoMode),
    };

    final extension = format == ReportFormat.pdf ? 'pdf' : 'xlsx';
    final filename =
        'StockSense_inventory_report_${_fileDateFormat.format(report.generatedAt)}.$extension';

    if (kIsWeb) {
      _downloadOnWeb(bytes, filename);
      return ReportDownload(path: filename, format: format);
    } else {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$filename');
      await file.writeAsBytes(bytes, flush: true);

      // This hands the downloaded file to the platform's associated viewer while
      // keeping the file accessible in the app's documents directory.
      await OpenFile.open(file.path);
      return ReportDownload(path: file.path, format: format);
    }
  }

  static void _downloadOnWeb(List<int> bytes, String filename) {
    // ignore: avoid_web_libraries_in_flutter
    final blob = html.Blob([bytes]);
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement(href: url)
      ..setAttribute('download', filename)
      ..click();
    html.Url.revokeObjectUrl(url);
  }

  static Future<_ReportData> _loadReport() async {
    final generatedAt = DateTime.now();
    final results = await Future.wait([
      InventoryService.getInventoryItems(limit: 10000),
      InventoryService.getStockMovements(limit: 10000),
    ]);
    final items = results[0] as List<InventoryItem>;
    final movements = results[1] as List<StockMovement>;
    final predictions = await Future.wait(
      items.map((item) => InventoryService.getItemPrediction(item.id)),
    );

    return _ReportData(
      businessName: _businessName(),
      generatedAt: generatedAt,
      items: items..sort((a, b) => a.name.compareTo(b.name)),
      movements: movements..sort((a, b) => b.timestamp.compareTo(a.timestamp)),
      predictions: predictions.whereType<StockPrediction>().toList(),
    );
  }

  static String _businessName() {
    final user = AuthService.currentUser;
    if (user == null) return 'StockSense Business';
    if ((user.organizationId ?? '').trim().isNotEmpty) {
      return '${user.displayName} (${user.organizationId})';
    }
    return user.displayName.trim().isEmpty
        ? 'StockSense Business'
        : user.displayName;
  }

  static Future<Uint8List> _buildPdf(_ReportData report,
      {required bool isDemoMode}) async {
    final document = pw.Document();
    document.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: const pw.EdgeInsets.all(24),
        header: (_) => _pdfHeader(report, isDemoMode: isDemoMode),
        footer: (context) => pw.Align(
          alignment: pw.Alignment.centerRight,
          child: pw.Text('Page ${context.pageNumber} of ${context.pagesCount}'),
        ),
        build: (context) => [
          if (isDemoMode) _pdfDemoWatermark(),
          _pdfSection('Current stock levels'),
          _pdfTable(
            [
              'Item',
              'Quantity',
              'Unit',
              'Category',
              'Restock threshold',
              'Unit price',
              'Stock value'
            ],
            report.items
                .map((item) => [
                      item.name,
                      '${item.quantity}',
                      item.unit,
                      item.category,
                      '${item.reorderLevel}',
                      _ksh(item.unitPrice),
                      _ksh(item.unitPrice * item.quantity),
                    ])
                .toList(),
          ),
          _pdfSection('Low stock / restock alerts'),
          _pdfTable(
            ['Alert', 'Item', 'Current stock', 'Threshold', 'Category'],
            report.lowStockItems
                .map((item) => [
                      item.quantity == 0 ? 'OUT OF STOCK' : 'RESTOCK REQUIRED',
                      item.name,
                      '${item.quantity} ${item.unit}',
                      '${item.reorderLevel} ${item.unit}',
                      item.category,
                    ])
                .toList(),
            emptyMessage: 'No low-stock items at the generated time.',
          ),
          _pdfSection('Category breakdown'),
          _pdfTable(
            ['Category', 'Item', 'Quantity', 'Unit', 'Stock value'],
            report.categoryRows,
          ),
          _pdfSection('AI analytics summary'),
          ...report.insights.map((insight) => pw.Padding(
                padding: const pw.EdgeInsets.only(bottom: 4),
                child: pw.Text('• $insight'),
              )),
          _pdfSection('Stock movements / history'),
          _pdfTable(
            [
              'Date',
              'Direction',
              'Item',
              'Quantity',
              'Unit',
              'Reason',
              'Recorded by'
            ],
            report.movements
                .map((movement) => [
                      _dateTimeFormat.format(movement.timestamp),
                      _movementLabel(movement.type),
                      movement.itemName,
                      '${movement.quantity}',
                      report.unitFor(movement.itemId),
                      movement.reason,
                      movement.userName,
                    ])
                .toList(),
            emptyMessage: 'No movements were recorded for this period.',
          ),
        ],
      ),
    );
    return document.save();
  }

  static pw.Widget _pdfHeader(_ReportData report, {required bool isDemoMode}) =>
      pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('StockSense Inventory Report',
              style:
                  pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
          pw.Text('Business: ${report.businessName}'),
          pw.Text('Generated: ${_dateTimeFormat.format(report.generatedAt)}'),
          pw.Text('Report period: $_periodLabel'),
          pw.SizedBox(height: 12),
        ],
      );

  static pw.Widget _pdfDemoWatermark() => pw.Container(
        padding: const pw.EdgeInsets.all(8),
        decoration: pw.BoxDecoration(
          color: PdfColors.orange100,
          border: pw.Border.all(color: PdfColors.orange800, width: 2),
          borderRadius: pw.BorderRadius.circular(4),
        ),
        child: pw.Text(
          'DEMO MODE — Sample Data Only',
          style: pw.TextStyle(
            color: PdfColors.orange800,
            fontSize: 12,
            fontWeight: pw.FontWeight.bold,
          ),
          textAlign: pw.TextAlign.center,
        ),
      );

  static pw.Widget _pdfSection(String title) => pw.Padding(
        padding: const pw.EdgeInsets.only(top: 14, bottom: 6),
        child: pw.Text(title,
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
      );

  static pw.Widget _pdfTable(List<String> headers, List<List<String>> rows,
      {String? emptyMessage}) {
    if (rows.isEmpty) return pw.Text(emptyMessage ?? 'No records available.');
    return pw.TableHelper.fromTextArray(
      headers: headers,
      data: rows,
      headerStyle:
          pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.blueGrey700),
      cellStyle: const pw.TextStyle(fontSize: 8),
      cellAlignment: pw.Alignment.centerLeft,
      cellPadding: const pw.EdgeInsets.all(3),
    );
  }

  static Uint8List _buildExcel(_ReportData report, {required bool isDemoMode}) {
    final workbook = Excel.createExcel();
    workbook.delete('Sheet1');
    _writeSheet(
      workbook,
      'Stock Levels',
      report,
      isDemoMode: isDemoMode,
      rows: [
        [
          'Item',
          'Quantity',
          'Unit',
          'Category',
          'Restock Threshold',
          'Unit Price (KSh)',
          'Stock Value (KSh)'
        ],
        ...report.items.map((item) => [
              item.name,
              item.quantity,
              item.unit,
              item.category,
              item.reorderLevel,
              item.unitPrice,
              item.unitPrice * item.quantity
            ]),
      ],
    );
    _writeSheet(workbook, 'Movements', report, isDemoMode: isDemoMode, rows: [
      [
        'Date',
        'Direction',
        'Item',
        'Quantity',
        'Unit',
        'Reason',
        'Recorded By'
      ],
      ...report.movements.map((movement) => [
            _dateTimeFormat.format(movement.timestamp),
            _movementLabel(movement.type),
            movement.itemName,
            movement.quantity,
            report.unitFor(movement.itemId),
            movement.reason,
            movement.userName
          ]),
    ]);
    _writeSheet(workbook, 'Restock Alerts', report,
        isDemoMode: isDemoMode,
        rows: [
          [
            'Alert',
            'Item',
            'Current Stock',
            'Unit',
            'Restock Threshold',
            'Category'
          ],
          ...report.lowStockItems.map((item) => [
                item.quantity == 0 ? 'OUT OF STOCK' : 'RESTOCK REQUIRED',
                item.name,
                item.quantity,
                item.unit,
                item.reorderLevel,
                item.category
              ]),
        ]);
    _writeSheet(
      workbook,
      'Categories',
      report,
      isDemoMode: isDemoMode,
      rows: [
        ['Category', 'Item', 'Quantity', 'Unit', 'Stock Value (KSh)'],
        ...report.categoryExcelRows,
      ],
    );
    _writeSheet(
      workbook,
      'AI Analytics',
      report,
      isDemoMode: isDemoMode,
      rows: [
        ['AI analytics summary'],
        ...report.insights.map((insight) => [insight]),
      ],
    );
    return Uint8List.fromList(workbook.encode()!);
  }

  static void _writeSheet(Excel workbook, String name, _ReportData report,
      {required bool isDemoMode, required List<List<dynamic>> rows}) {
    final sheet = workbook[name];
    sheet.appendRow([TextCellValue('StockSense Inventory Report')]);
    sheet.appendRow([TextCellValue('Business: ${report.businessName}')]);
    sheet.appendRow([
      TextCellValue('Generated: ${_dateTimeFormat.format(report.generatedAt)}')
    ]);
    sheet.appendRow([TextCellValue('Report period: $_periodLabel')]);
    if (isDemoMode) {
      sheet.appendRow([TextCellValue('DEMO MODE — Sample Data Only')]);
    }
    sheet.appendRow([]);
    for (final row in rows) {
      sheet.appendRow(row.map(_excelValue).toList());
    }
    for (var index = 0;
        index < (rows.isNotEmpty ? rows.first.length : 1);
        index++) {
      sheet.setColumnWidth(index, 18);
    }
  }

  static CellValue _excelValue(dynamic value) {
    if (value is int) return IntCellValue(value);
    if (value is double) return DoubleCellValue(value);
    return TextCellValue(value?.toString() ?? '');
  }

  static String _movementLabel(MovementType type) => switch (type) {
        MovementType.stockIn => 'Inbound',
        MovementType.stockOut => 'Outbound',
        MovementType.adjustment => 'Adjustment',
      };

  static String _ksh(num value) => 'KSh ${_currencyFormat.format(value)}';
}

class _ReportData {
  final String businessName;
  final DateTime generatedAt;
  final List<InventoryItem> items;
  final List<StockMovement> movements;
  final List<StockPrediction> predictions;

  const _ReportData(
      {required this.businessName,
      required this.generatedAt,
      required this.items,
      required this.movements,
      required this.predictions});

  List<InventoryItem> get lowStockItems =>
      items.where((item) => item.quantity <= item.reorderLevel).toList();

  List<_CategorySummary> get categories {
    final groups = <String, List<InventoryItem>>{};
    for (final item in items) {
      groups
          .putIfAbsent(
              item.category.trim().isEmpty ? 'Uncategorised' : item.category,
              () => [])
          .add(item);
    }
    return groups.entries
        .map((entry) => _CategorySummary(entry.key, entry.value))
        .toList()
      ..sort((a, b) => a.name.compareTo(b.name));
  }

  List<List<String>> get categoryRows => [
        for (final category in categories) ...[
          for (final item in category.items)
            [
              category.name,
              item.name,
              '${item.quantity}',
              item.unit,
              ReportService._ksh(item.quantity * item.unitPrice),
            ],
          [
            '${category.name} subtotal',
            '${category.items.length} item(s)',
            '${category.quantity}',
            '',
            ReportService._ksh(category.value),
          ],
        ],
      ];

  List<List<dynamic>> get categoryExcelRows => [
        for (final category in categories) ...[
          for (final item in category.items)
            [
              category.name,
              item.name,
              item.quantity,
              item.unit,
              item.quantity * item.unitPrice,
            ],
          [
            '${category.name} subtotal',
            '${category.items.length} item(s)',
            category.quantity,
            '',
            category.value,
          ],
        ],
      ];

  String unitFor(String itemId) =>
      items
          .where((item) => item.id == itemId)
          .map((item) => item.unit)
          .firstOrNull ??
      'Units';

  List<String> get insights {
    final outbound = <String, int>{};
    for (final movement in movements
        .where((movement) => movement.type == MovementType.stockOut)) {
      outbound.update(movement.itemName, (value) => value + movement.quantity,
          ifAbsent: () => movement.quantity);
    }
    final topItems = outbound.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final stockouts = predictions
        .where(
            (prediction) => prediction.needsRestock || prediction.daysLeft <= 7)
        .toList()
      ..sort((a, b) => a.daysLeft.compareTo(b.daysLeft));
    final inbound = movements
        .where((movement) => movement.type == MovementType.stockIn)
        .fold<int>(0, (total, movement) => total + movement.quantity);
    final outboundTotal = movements
        .where((movement) => movement.type == MovementType.stockOut)
        .fold<int>(0, (total, movement) => total + movement.quantity);
    return [
      if (topItems.isEmpty)
        'No outbound movement data is available yet to identify top-moving items.'
      else
        'Top-moving items: ${topItems.take(3).map((entry) => '${entry.key} (${entry.value} units outbound)').join(', ')}.',
      if (stockouts.isEmpty)
        'No predicted stockouts are currently flagged.'
      else
        'Predicted stockouts/restocks: ${stockouts.take(3).map((prediction) => '${prediction.itemName} (${prediction.daysLeft} days)').join(', ')}.',
      'Movement trend: $inbound units inbound and $outboundTotal units outbound over ${ReportService._periodLabel.toLowerCase()}.',
      '${lowStockItems.length} item(s) are at or below their restock threshold.',
    ];
  }
}

class _CategorySummary {
  final String name;
  final List<InventoryItem> items;

  const _CategorySummary(this.name, this.items);

  int get quantity => items.fold(0, (total, item) => total + item.quantity);
  double get value =>
      items.fold(0, (total, item) => total + item.quantity * item.unitPrice);
}
