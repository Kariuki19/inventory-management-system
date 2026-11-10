import 'package:flutter_test/flutter_test.dart';
import 'package:inventory_management_system/services/trial_policy.dart';

void main() {
  final start = DateTime.utc(2026, 11, 10, 9, 30);
  const minute = Duration(minutes: 1);
  const second = Duration(seconds: 1);
  const hour = Duration(hours: 1);

  group('demo length', () {
    test('is exactly one hour', () => expect(TrialPolicy.duration, hour));

    test('expiry is one hour after the stored start', () {
      expect(TrialPolicy.expiryOf(start), DateTime.utc(2026, 11, 10, 10, 30));
    });

    test('active at the start and after 59 minutes', () {
      expect(TrialPolicy.evaluate(start, start), TrialStatus.active);
      expect(TrialPolicy.evaluate(start, start.add(minute * 59)),
          TrialStatus.active);
    });

    test('active one second before the hour', () {
      expect(TrialPolicy.evaluate(start, start.add(hour - second)),
          TrialStatus.active);
    });

    test('expired at exactly one hour', () {
      expect(TrialPolicy.evaluate(start, start.add(hour)), TrialStatus.expired);
    });

    test('expired one second after the hour and long after', () {
      expect(TrialPolicy.evaluate(start, start.add(hour + second)),
          TrialStatus.expired);
      expect(TrialPolicy.evaluate(start, start.add(const Duration(days: 3))),
          TrialStatus.expired);
    });
  });

  group('validation', () {
    test('missing start is invalid', () {
      expect(TrialPolicy.evaluate(null, start), TrialStatus.invalid);
    });

    test('a start far in the future is invalid', () {
      expect(TrialPolicy.evaluate(start.add(hour * 2), start),
          TrialStatus.invalid);
    });

    test('a small clock difference is tolerated, a large one is not', () {
      expect(TrialPolicy.evaluate(start.add(minute * 10), start),
          TrialStatus.active);
      expect(TrialPolicy.evaluate(start.add(minute * 30), start),
          TrialStatus.invalid);
    });
  });

  group('time remaining', () {
    test('counts down and never goes negative', () {
      expect(TrialPolicy.remaining(start, start), hour);
      expect(TrialPolicy.remaining(start, start.add(minute * 15)),
          const Duration(minutes: 45));
      expect(TrialPolicy.remaining(start, start.add(hour - second)), second);
      expect(TrialPolicy.remaining(start, start.add(hour)), Duration.zero);
      expect(TrialPolicy.remaining(start, start.add(hour * 3)), Duration.zero);
    });

    test('never shows more than the full hour', () {
      expect(TrialPolicy.remaining(start.add(minute * 10), start), hour);
    });
  });

  group('logout / new account cannot restart the demo', () {
    test('the earlier start always wins', () {
      final newer = start.add(minute * 30);
      expect(TrialPolicy.earliest(start, newer), start);
      expect(TrialPolicy.earliest(newer, start), start);
      expect(TrialPolicy.earliest(null, start), start);
      expect(TrialPolicy.earliest(start, null), start);
      expect(TrialPolicy.earliest(null, null), isNull);
    });

    test('a later account start does not extend the demo', () {
      final effective = TrialPolicy.earliest(start, start.add(minute * 30));
      expect(TrialPolicy.evaluate(effective, start.add(hour)),
          TrialStatus.expired);
    });
  });
}
