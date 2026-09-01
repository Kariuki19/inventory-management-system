import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../features/inventory/services/demo_service.dart';

// Re-export DemoEndedReason from demo_service for convenience
export '../../features/inventory/services/demo_service.dart' show DemoEndedReason;

/// Manages the demo mode session state and expiration logic
class DemoProvider extends ChangeNotifier {
  Timer? _tickTimer;
  Duration _remainingTime = Duration.zero;
  bool _sessionActive = false;
  DemoEndedReason? _endReason;
  VoidCallback? _onExpired;

  Duration get remainingTime => _remainingTime;
  bool get isSessionActive => _sessionActive;
  DemoEndedReason? get endReason => _endReason;

  DemoProvider();

  /// Initialize the demo session and start the countdown timer
  Future<void> initializeSession() async {
    _sessionActive = await DemoService.validateSession();
    if (!_sessionActive) {
      notifyListeners();
      return;
    }

    await DemoService.startSession();
    _sessionActive = true;
    _refreshRemaining();
    _startTimer();
    notifyListeners();
  }

  /// Start the periodic timer for demo countdown
  void _startTimer() {
    _tickTimer?.cancel();
    _tickTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _refreshRemaining();
    });
  }

  /// Refresh remaining time and check for expiration
  Future<void> _refreshRemaining() async {
    final remaining = await DemoService.getRemainingTime();
    final hasChanged = _remainingTime != remaining;

    _remainingTime = remaining;

    // Check if session has expired
    if (remaining <= Duration.zero && _sessionActive) {
      _sessionActive = false;
      _endReason = DemoEndedReason.timeExpired;
      await _handleSessionEnd(DemoEndedReason.timeExpired);
      notifyListeners();
      return;
    }

    if (hasChanged) {
      notifyListeners();
    }
  }

  /// Set callback to be called when session expires
  void setOnExpiredCallback(VoidCallback callback) {
    _onExpired = callback;
  }

  /// Handle manual exit from demo
  Future<void> exitDemo() async {
    _tickTimer?.cancel();
    _sessionActive = false;
    _endReason = DemoEndedReason.manualExit;
    await _handleSessionEnd(DemoEndedReason.manualExit);
    notifyListeners();
  }

  /// Internal method to handle session termination
  Future<void> _handleSessionEnd(DemoEndedReason reason) async {
    _tickTimer?.cancel();
    await DemoService.clearSession(reason: reason);
    _onExpired?.call();
  }

  /// Get the session end reason (for analytics)
  DemoEndedReason? getSessionEndReason() {
    return _endReason;
  }

  /// Check if session is still valid (with background network validation)
  Future<bool> validateSessionRemote() async {
    // In production, this would make an actual API call to validate the session
    return await DemoService.validateSession();
  }

  /// Handle network loss during demo - still navigate but retry session cleanup
  /// 
  /// Edge case: Network loss during demo session expiration
  /// - User can't reach backend to validate/confirm session closure
  /// - Solution: Route user to Demo Ended screen locally (don't block on network)
  /// - Background: Retry session cleanup with timeout
  /// - Result: User experience not disrupted by network failures
  void handleNetworkLoss() async {
    // Attempt local cleanup but don't block navigation
    try {
      if (_sessionActive) {
        _sessionActive = false;
        _tickTimer?.cancel();
        // Try to clean up, but don't wait long
        await Future.delayed(const Duration(milliseconds: 500));
        await DemoService.clearSession(reason: DemoEndedReason.timeExpired)
            .timeout(const Duration(seconds: 2))
            .catchError((_) {
          // Silently fail if network is down - user is already on Demo Ended screen
        });
      }
    } catch (_) {
      // Continue anyway - UI not blocked by network errors
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _tickTimer?.cancel();
    super.dispose();
  }
}
