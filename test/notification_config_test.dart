import 'package:flutter_test/flutter_test.dart';
import 'package:inventory_management_system/config/notification_config.dart';

void main() {
  test('email sending is off unless credentials are supplied at build time',
      () {
    expect(NotificationConfig.isEmailConfigured, isFalse);
  });

  test('the status never claims a placeholder setup is valid', () {
    expect(NotificationConfig.emailConfigStatus,
        isNot('Email configuration is valid.'));
  });
}
