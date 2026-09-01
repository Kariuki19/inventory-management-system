import 'package:shared_preferences/shared_preferences.dart';
import '../../auth/services/auth_service.dart';

class TrialService {
  static const String _firstLaunchKey = 'first_launch_date';
  static const int trialDurationDays = 14;

  /// Returns the first launch date (now from user profile).
  static Future<DateTime> getFirstLaunchDate() async {
    final user = AuthService.currentUser;
    if (user != null && user.trialStartDate != null) {
      return user.trialStartDate!;
    }
    
    // Fallback (e.g., if user profile hasn't loaded or field is missing)
    final prefs = await SharedPreferences.getInstance();
    final String? firstLaunchStr = prefs.getString(_firstLaunchKey);

    if (firstLaunchStr == null) {
      final now = DateTime.now();
      await prefs.setString(_firstLaunchKey, now.toIso8601String());
      return now;
    }

    return DateTime.parse(firstLaunchStr);
  }

  /// Checks if the trial period has expired.
  static Future<bool> isTrialExpired() async {
    final firstLaunch = await getFirstLaunchDate();
    final now = DateTime.now();
    final difference = now.difference(firstLaunch).inDays;
    
    return difference >= trialDurationDays;
  }

  /// Returns the number of days remaining in the trial.
  static Future<int> getRemainingDays() async {
    final remaining = await getRemainingDuration();
    if (remaining <= Duration.zero) return 0;
    return remaining.inDays;
  }

  /// Exact time remaining in the authenticated demo period.
  static Future<Duration> getRemainingDuration() async {
    final firstLaunch = await getFirstLaunchDate();
    final expiry = firstLaunch.add(const Duration(days: trialDurationDays));
    final remaining = expiry.difference(DateTime.now());
    return remaining.isNegative ? Duration.zero : remaining;
  }

  static Future<DateTime> getExpiryTime() async {
    final firstLaunch = await getFirstLaunchDate();
    return firstLaunch.add(const Duration(days: trialDurationDays));
  }

  /// Reset trial (for development/testing purposes only)
  static Future<void> resetTrial() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_firstLaunchKey);
  }
}
