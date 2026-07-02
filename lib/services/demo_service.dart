import 'package:shared_preferences/shared_preferences.dart';

/// Manages time-limited guest demo sessions (no account required).
class DemoService {
  static const String _sessionStartKey = 'demo_session_start';

  /// Guest sandbox duration — change here to use 30 min, 24 h, or 7 days.
  static const Duration guestDemoDuration = Duration(minutes: 5);

  static Future<void> startSession() async {
    final prefs = await SharedPreferences.getInstance();
    final existing = prefs.getString(_sessionStartKey);

    if (existing != null) {
      final start = DateTime.parse(existing);
      if (DateTime.now().difference(start) < guestDemoDuration) {
        return;
      }
    }

    await prefs.setString(_sessionStartKey, DateTime.now().toIso8601String());
  }

  static Future<DateTime?> getSessionStart() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(_sessionStartKey);
    if (value == null) return null;
    return DateTime.parse(value);
  }

  static Future<DateTime> getExpiryTime() async {
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
    final start = await getSessionStart();
    if (start == null) return false;
    return DateTime.now().difference(start) < guestDemoDuration;
  }

  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionStartKey);
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
