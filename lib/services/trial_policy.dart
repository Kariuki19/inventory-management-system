enum TrialStatus { active, expired, invalid }

class TrialPolicy {
  /// The demo lasts exactly one hour from the moment it starts.
  static const Duration duration = Duration(hours: 1);

  /// How far in the future a start time may be before it is rejected.
  static const Duration maxClockSkew = Duration(minutes: 15);

  /// The demo ends exactly [duration] after [start].
  static DateTime expiryOf(DateTime start) => start.add(duration);

  static TrialStatus evaluate(DateTime? start, DateTime now) {
    if (start == null) return TrialStatus.invalid;
    if (start.isAfter(now.add(maxClockSkew))) return TrialStatus.invalid;
    return now.difference(start) >= duration
        ? TrialStatus.expired
        : TrialStatus.active;
  }

  /// Time left: never negative and never more than the full hour.
  static Duration remaining(DateTime start, DateTime now) {
    final left = expiryOf(start).difference(now);
    if (left <= Duration.zero) return Duration.zero;
    return left > duration ? duration : left;
  }

  /// A start time can only move earlier, never later.
  static DateTime? earliest(DateTime? a, DateTime? b) {
    if (a == null) return b;
    if (b == null) return a;
    return a.isBefore(b) ? a : b;
  }
}