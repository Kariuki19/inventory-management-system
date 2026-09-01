import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Provider for managing Demo Mode state globally
/// Controls whether the app is in Live Mode or Read-Only Demo Mode
class DemoModeProvider with ChangeNotifier {
  static const String _demoModeKey = 'is_demo_mode';

  bool _isDemoMode = false;

  bool get isDemoMode => _isDemoMode;

  DemoModeProvider() {
    _loadDemoModeState();
  }

  /// Load demo mode state from SharedPreferences
  Future<void> _loadDemoModeState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isDemoMode = prefs.getBool(_demoModeKey) ?? false;
      notifyListeners();
    } catch (e) {
      // Default to live mode if loading fails
      _isDemoMode = false;
      notifyListeners();
    }
  }

  /// Toggle between Live Mode and Demo Mode
  Future<void> toggleDemoMode() async {
    _isDemoMode = !_isDemoMode;
    await _saveDemoModeState();
    notifyListeners();
  }

  /// Set demo mode explicitly
  Future<void> setDemoMode(bool value) async {
    _isDemoMode = value;
    await _saveDemoModeState();
    notifyListeners();
  }

  /// Save demo mode state to SharedPreferences
  Future<void> _saveDemoModeState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_demoModeKey, _isDemoMode);
    } catch (e) {
      // Ignore save errors
    }
  }

  /// Check if a write operation should be blocked
  bool shouldBlockWrite() {
    return _isDemoMode;
  }

  /// Get the appropriate collection name based on demo mode
  String getCollectionName(String baseCollectionName) {
    if (_isDemoMode) {
      return 'demo_$baseCollectionName';
    }
    return baseCollectionName;
  }
}
