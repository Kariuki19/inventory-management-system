import 'package:shared_preferences/shared_preferences.dart';

/// Enum for tracking why a demo session ended
/// Used for analytics and user experience differentiation
enum DemoEndedReason { 
  /// Demo session timer expired automatically
  timeExpired,
  /// User manually exited demo
  manualExit,
}

class DemoService {
  static const String _sessionStartKey = 'demo_session_start';
  static const String _sessionTokenKey = 'demo_session_token';
  static const String _sessionEndedReasonKey = 'demo_session_ended_reason';
  static const String _sessionPausedKey = 'demo_session_paused';
  static const String _sessionPausedRemainingKey =
      'demo_session_paused_remaining';

  /// Demo duration for guest/anonymous users - Backend should enforce server-side
  static const Duration guestDemoDuration = Duration(hours: 1);

  /// Generate a unique session token for server-side validation
  /// 
  /// In production, the backend should validate this token to prevent tampering
  /// (e.g., client-side timer manipulation). The token allows the backend to
  /// correlate this session with server logs and enforce the true expiration.
  static String _generateSessionToken() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  static Future<void> startSession() async {
    final prefs = await SharedPreferences.getInstance();
    final existing = prefs.getString(_sessionStartKey);
    final isPaused = prefs.getBool(_sessionPausedKey) ?? false;

    if (isPaused) {
      return;
    }

    if (existing != null) {
      final start = DateTime.parse(existing);
      if (DateTime.now().difference(start) < guestDemoDuration) {
        return;
      }
    }

    // Start new session with token
    await prefs.setString(_sessionStartKey, DateTime.now().toIso8601String());
    await prefs.setString(_sessionTokenKey, _generateSessionToken());
    await prefs.remove(_sessionEndedReasonKey);
    await prefs.remove(_sessionPausedKey);
    await prefs.remove(_sessionPausedRemainingKey);
  }

  static Future<DateTime?> getSessionStart() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(_sessionStartKey);
    if (value == null) return null;
    return DateTime.parse(value);
  }

  /// Get the current session token (used for server-side validation)
  static Future<String?> getSessionToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_sessionTokenKey);
  }

  /// Validate session is still active (backend would verify this server-side)
  /// 
  /// This method checks both local state and session token validity.
  /// In production, this should make an API call to the backend to:
  /// - Verify the session token is valid (tamper protection)
  /// - Validate the session hasn't expired server-side
  /// - Prevent replay attacks with stale tokens
  /// 
  /// Current implementation: Local validation only (ready for backend integration)
  static Future<bool> validateSession() async {
    // In production, this would make an API call to verify the session server-side
    // For now, we check locally and flag for backend validation
    if (await isSessionExpired()) {
      return false;
    }
    final token = await getSessionToken();
    return token != null;
  }

  static Future<DateTime> getExpiryTime() async {
    final prefs = await SharedPreferences.getInstance();
    final isPaused = prefs.getBool(_sessionPausedKey) ?? false;

    if (isPaused) {
      final pausedRemaining = prefs.getInt(_sessionPausedRemainingKey);
      final remaining = Duration(milliseconds: pausedRemaining ?? 0);
      return DateTime.now().add(remaining);
    }

    final start = await getSessionStart();
    return (start ?? DateTime.now()).add(guestDemoDuration);
  }

  static Future<Duration> getRemainingTime() async {
    final expiry = await getExpiryTime();
    final remaining = expiry.difference(DateTime.now());
    return remaining.isNegative ? Duration.zero : remaining;
  }

  static Future<bool> isSessionExpired() async {
    final remaining = await getRemainingTime();
    return remaining <= Duration.zero;
  }

  static Future<bool> hasActiveSession() async {
    final token = await getSessionToken();
    if (token == null) return false;

    final remaining = await getRemainingTime();
    return remaining > Duration.zero;
  }

  /// Pause the current session without clearing the remaining time.
  /// Returns false when there is no resumable session to pause.
  static Future<bool> pauseSession() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_sessionTokenKey);
    if (token == null) return false;

    final remaining = await getRemainingTime();
    if (remaining <= Duration.zero) {
      return false;
    }

    await prefs.setBool(_sessionPausedKey, true);
    await prefs.setInt(_sessionPausedRemainingKey, remaining.inMilliseconds);
    return true;
  }

  /// Resume a paused session without resetting elapsed or remaining time.
  /// Returns false when the session cannot be resumed.
  static Future<bool> resumeSession() async {
    final prefs = await SharedPreferences.getInstance();
    final isPaused = prefs.getBool(_sessionPausedKey) ?? false;
    if (!isPaused) {
      return await hasActiveSession();
    }

    final token = prefs.getString(_sessionTokenKey);
    final pausedRemaining = prefs.getInt(_sessionPausedRemainingKey);
    if (token == null || pausedRemaining == null || pausedRemaining <= 0) {
      return false;
    }

    final remaining = Duration(milliseconds: pausedRemaining);
    final adjustedStart = DateTime.now().subtract(
      guestDemoDuration - remaining,
    );

    await prefs.setString(_sessionStartKey, adjustedStart.toIso8601String());
    await prefs.remove(_sessionPausedKey);
    await prefs.remove(_sessionPausedRemainingKey);
    return true;
  }

  /// Clear session with optional reason for tracking
  static Future<void> clearSession({
    DemoEndedReason reason = DemoEndedReason.timeExpired,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionStartKey);
    await prefs.remove(_sessionTokenKey);
    await prefs.remove(_sessionPausedKey);
    await prefs.remove(_sessionPausedRemainingKey);
    // Store reason for analytics before clearing
    await prefs.setString(_sessionEndedReasonKey, reason.toString());
  }

  /// Get the reason why the session ended
  static Future<DemoEndedReason?> getSessionEndReason() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(_sessionEndedReasonKey);
    if (value == null) return null;
    return value.contains('timeExpired')
        ? DemoEndedReason.timeExpired
        : DemoEndedReason.manualExit;
  }

  /// Clear the session end reason after consuming it
  static Future<void> clearSessionEndReason() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionEndedReasonKey);
  }

  static String formatDuration(Duration duration) {
    final totalSeconds = duration.inSeconds;
    if (totalSeconds <= 0) return '00:00';

    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final seconds = totalSeconds % 60;

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:'
          '${minutes.toString().padLeft(2, '0')}:'
          '${seconds.toString().padLeft(2, '0')}';
    }

    return '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }

  static String formatDurationLong(Duration duration) {
    if (duration <= Duration.zero) return 'Expired';

    final days = duration.inDays;
    if (days > 0) {
      final hours = duration.inHours % 24;
      return '$days day${days == 1 ? '' : 's'}'
          '${hours > 0 ? ', $hours hr${hours == 1 ? '' : 's'}' : ''}';
    }

    return formatDuration(duration);
  }
}
