import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../inventory/models/inventory_item.dart';
import '../../stock/models/stock_movement.dart';
import '../../predictions/models/stock_prediction.dart';

class MockInventoryService {
  static final List<InventoryItem> _items = [
    InventoryItem(
      id: 'demo_1',
      name: 'Arduino Uno R3',
      category: 'Electronics',
      quantity: 45,
      reorderLevel: 15,
      unitPrice: 25.0,
      description: 'Microcontroller board',
      supplier: 'Demo Supplier Inc.',
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
      updatedAt: DateTime.now().subtract(const Duration(days: 5)),
      isPerishable: false,
    ),
    InventoryItem(
      id: 'demo_2',
      name: 'Raspberry Pi 4 Model B',
      category: 'Electronics',
      quantity: 12,
      reorderLevel: 10,
      unitPrice: 55.0,
      description: 'Single board computer',
      supplier: 'Demo Supplier Inc.',
      createdAt: DateTime.now().subtract(const Duration(days: 12)),
      updatedAt: DateTime.now().subtract(const Duration(days: 12)),
      isPerishable: false,
    ),
    InventoryItem(
      id: 'demo_3',
      name: '10k Ohm Resistor Pack (100pcs)',
      category: 'Electronic Components',
      quantity: 200,
      reorderLevel: 50,
      unitPrice: 5.0,
      description: 'Carbon film resistors',
      supplier: 'Demo Supplier Inc.',
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
      updatedAt: DateTime.now().subtract(const Duration(days: 30)),
      isPerishable: false,
    ),
    InventoryItem(
      id: 'demo_4',
      name: 'Organic Rice (50kg)',
      category: 'Groceries',
      quantity: 8,
      reorderLevel: 15,
      unitPrice: 45.0,
      description: 'Wholesale basmati rice',
      supplier: 'Demo Supplier Inc.',
      createdAt: DateTime.now().subtract(const Duration(days: 20)),
      updatedAt: DateTime.now().subtract(const Duration(days: 20)),
      isPerishable: true,
      expiryDate: DateTime.now().add(const Duration(days: 180)),
    ),
    InventoryItem(
      id: 'demo_5',
      name: 'Canned Beans Case',
      category: 'Groceries',
      quantity: 120,
      reorderLevel: 40,
      unitPrice: 18.5,
      description: '24 cans per case',
      supplier: 'Demo Supplier Inc.',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      updatedAt: DateTime.now().subtract(const Duration(days: 2)),
      isPerishable: true,
      expiryDate: DateTime.now().add(const Duration(days: 365)),
    ),
    InventoryItem(
      id: 'demo_6',
      name: 'Wheat Flour (20kg)',
      category: 'Groceries',
      quantity: 5,
      reorderLevel: 20,
      unitPrice: 15.0,
      description: 'All-purpose flour',
      supplier: 'Demo Supplier Inc.',
      createdAt: DateTime.now().subtract(const Duration(days: 45)),
      updatedAt: DateTime.now().subtract(const Duration(days: 45)),
      isPerishable: true,
      expiryDate: DateTime.now().add(const Duration(days: 60)),
    ),
    InventoryItem(
      id: 'demo_7',
      name: 'Soldering Iron Kit',
      category: 'Tools',
      quantity: 30,
      reorderLevel: 10,
      unitPrice: 35.0,
      description: 'Variable temp with tips',
      supplier: 'Demo Supplier Inc.',
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
      updatedAt: DateTime.now().subtract(const Duration(days: 10)),
      isPerishable: false,
    ),
    InventoryItem(
      id: 'demo_8',
      name: 'Digital Multimeter',
      category: 'Tools',
      quantity: 25,
      reorderLevel: 8,
      unitPrice: 42.0,
      description: 'Auto-ranging multimeter',
      supplier: 'Demo Supplier Inc.',
      createdAt: DateTime.now().subtract(const Duration(days: 15)),
      updatedAt: DateTime.now().subtract(const Duration(days: 15)),
      isPerishable: false,
    ),
    InventoryItem(
      id: 'demo_9',
      name: 'LED Assortment Kit',
      category: 'Electronic Components',
      quantity: 85,
      reorderLevel: 30,
      unitPrice: 12.0,
      description: '5mm LEDs mixed colors',
      supplier: 'Demo Supplier Inc.',
      createdAt: DateTime.now().subtract(const Duration(days: 8)),
      updatedAt: DateTime.now().subtract(const Duration(days: 8)),
      isPerishable: false,
    ),
    InventoryItem(
      id: 'demo_10',
      name: 'Cooking Oil (20L)',
      category: 'Groceries',
      quantity: 0,
      reorderLevel: 10,
      unitPrice: 38.0,
      description: 'Vegetable cooking oil bulk',
      supplier: 'Demo Supplier Inc.',
      createdAt: DateTime.now().subtract(const Duration(days: 60)),
      updatedAt: DateTime.now().subtract(const Duration(days: 60)),
      isPerishable: true,
      expiryDate: DateTime.now().add(const Duration(days: 120)),
    ),
  ];

  static final List<StockMovement> _movements = [];
  
  static final StreamController<List<InventoryItem>> _itemsController = StreamController<List<InventoryItem>>.broadcast();
  static final StreamController<Map<String, dynamic>> _dashboardStatsController = StreamController<Map<String, dynamic>>.broadcast();
  static final StreamController<Map<String, int>> _categoryStatsController = StreamController<Map<String, int>>.broadcast();

  static void _notifyListeners() {
    _itemsController.add(_items);
    _dashboardStatsController.add(_calculateDashboardStats());
    _categoryStatsController.add(_calculateCategoryStats());
  }

  static Future<List<InventoryItem>> getInventoryItems({
    int limit = 20,
    DocumentSnapshot? lastDoc,
    String? searchQuery,
    String? category,
  }) async {
    var results = _items.toList();
    if (category != null && category != 'All') {
      results = results.where((i) => i.category == category).toList();
    }
    if (searchQuery != null && searchQuery.isNotEmpty) {
      results = results.where((i) => i.name.toLowerCase().contains(searchQuery.toLowerCase())).toList();
    }
    return results;
  }

  static Future<String> addInventoryItem(InventoryItem item) async {
    final newItem = item.copyWith(id: 'demo_${DateTime.now().millisecondsSinceEpoch}');
    _items.add(newItem);
    _notifyListeners();
    return newItem.id;
  }

  static Future<void> updateInventoryItem(InventoryItem item) async {
    final index = _items.indexWhere((i) => i.id == item.id);
    if (index != -1) {
      _items[index] = item;
      _notifyListeners();
    }
  }

  static Future<void> deleteInventoryItem(String itemId) async {
    _items.removeWhere((i) => i.id == itemId);
    _notifyListeners();
  }

  static Future<void> adjustStock(String itemId, int newQuantity, String reason) async {
    final index = _items.indexWhere((i) => i.id == itemId);
    if (index != -1) {
      _items[index] = _items[index].copyWith(quantity: newQuantity);
      _notifyListeners();
    }
  }

  static Future<List<StockMovement>> getStockMovements({String? itemId, int limit = 100}) async {
    var results = _movements.toList();
    if (itemId != null) {
      results = results.where((m) => m.itemId == itemId).toList();
    }
    return results.take(limit).toList();
  }

  static Future<Map<String, dynamic>> getDashboardStats() async {
    return _calculateDashboardStats();
  }

  static Map<String, dynamic> _calculateDashboardStats() {
    final totalItems = _items.length;
    final totalValue = _items.fold<double>(0, (sum, item) => sum + (item.quantity * item.unitPrice));
    final lowStockItems = _items.where((item) => item.quantity <= item.reorderLevel).length;
    final outOfStockItems = _items.where((item) => item.quantity == 0).length;
    
    return {
      'totalItems': totalItems,
      'totalValue': totalValue,
      'lowStockItems': lowStockItems,
      'outOfStockItems': outOfStockItems,
      'itemsNeedingRestock': lowStockItems,
    };
  }

  static Stream<Map<String, dynamic>> getDashboardStatsStream() {
    Future.microtask(() => _dashboardStatsController.add(_calculateDashboardStats()));
    return _dashboardStatsController.stream;
  }

  static Future<Map<String, int>> getCategoryStats() async {
    return _calculateCategoryStats();
  }

  static Map<String, int> _calculateCategoryStats() {
    final categoryStats = <String, int>{};
    for (final item in _items) {
      final cat = item.category.isNotEmpty ? item.category : 'Other';
      categoryStats[cat] = (categoryStats[cat] ?? 0) + item.quantity;
    }
    return categoryStats;
  }

  static Stream<Map<String, int>> getCategoryStatsStream() {
    Future.microtask(() => _categoryStatsController.add(_calculateCategoryStats()));
    return _categoryStatsController.stream;
  }

  static Future<List<String>> getCategories() async {
    return _items.map((e) => e.category).toSet().toList();
  }

  static Future<List<StockPrediction>> getStockPredictions({int limit = 20, DocumentSnapshot? lastDoc}) async {
    return _items.map((i) => StockPrediction(
      itemId: i.id,
      itemName: i.name,
      currentQuantity: i.quantity,
      averageDailyUsage: 1.5,
      daysLeft: i.quantity > 0 ? (i.quantity / 1.5).round() : 0,
      predictedDepletionDate: DateTime.now().add(Duration(days: i.quantity > 0 ? (i.quantity / 1.5).round() : 0)),
      needsRestock: i.quantity <= i.reorderLevel,
      confidence: PredictionConfidence.medium,
      calculatedAt: DateTime.now(),
    )).toList();
  }

  static Future<StockPrediction?> getItemPrediction(String itemId) async {
    final item = _items.firstWhere((i) => i.id == itemId, orElse: () => _items.first);
    return StockPrediction(
      itemId: item.id,
      itemName: item.name,
      currentQuantity: item.quantity,
      averageDailyUsage: 1.5,
      daysLeft: item.quantity > 0 ? (item.quantity / 1.5).round() : 0,
      predictedDepletionDate: DateTime.now().add(Duration(days: item.quantity > 0 ? (item.quantity / 1.5).round() : 0)),
      needsRestock: item.quantity <= item.reorderLevel,
      confidence: PredictionConfidence.medium,
      calculatedAt: DateTime.now(),
    );
  }

  static Future<StockPrediction> calculatePredictionForItem(InventoryItem item) async {
    return (await getItemPrediction(item.id))!;
  }

  static Future<List<Map<String, dynamic>>> getMonthlyMovementTrends({int monthsBack = 6}) async {
    return []; // Return empty for demo
  }

  static Stream<List<Map<String, dynamic>>> getMonthlyMovementTrendsStream({int monthsBack = 6}) {
    return Stream.value([]);
  }

  static Future<List<Map<String, dynamic>>> getInventoryItemsWithSnapshots({int limit = 20, DocumentSnapshot? lastDoc}) async {
    return _items.map((item) => {
      'item': item,
      'snapshot': null,
    }).toList();
  }
}
