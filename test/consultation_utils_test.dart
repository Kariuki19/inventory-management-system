import 'package:flutter_test/flutter_test.dart';
import 'package:inventory_management_system/utils/consultation_utils.dart';

void main() {
  test('validators accept good input and reject bad input', () {
    expect(ConsultationValidators.name('Wanjiku'), isNull);
    expect(ConsultationValidators.name(' '), isNotNull);
    expect(ConsultationValidators.email('wanjiku@example.com'), isNull);
    expect(ConsultationValidators.email('wanjiku@'), isNotNull);
    expect(ConsultationValidators.email(''), isNotNull);
    expect(ConsultationValidators.phone('+254 712 345 678'), isNull);
    expect(ConsultationValidators.phone('0712345678'), isNull);
    expect(ConsultationValidators.phone('12345'), isNotNull);
  });

  test('request body carries the plan and skips empty optional fields', () {
    final body = ConsultationRequest.buildBody(
      plan: 'Pro',
      name: 'Wanjiku Mwangi',
      email: 'wanjiku@example.com',
      phone: '0712345678',
      role: 'Owner/Founder',
      timeline: 'Immediately',
      contactMethods: ['Email', 'WhatsApp'],
    );
    expect(body, contains('Plan: Pro'));
    expect(body, contains('Preferred contact: Email, WhatsApp'));
    expect(body, isNot(contains('Company:')));
    expect(body, isNot(contains('Team size')));
    expect(body, isNot(contains('Demo minutes')));
  });

  test('demo requests include team size, minutes left and the reference', () {
    final body = ConsultationRequest.buildBody(
      plan: 'Basic',
      teamSize: 'Up to 5 users (\$30/month)',
      name: 'A B',
      email: 'a@b.co',
      phone: '0712345678',
      role: 'Manager',
      timeline: 'Just exploring',
      contactMethods: ['Phone'],
      source: 'In-app (demo)',
      trialMinutesLeft: 25,
      trialReference: 'abc123',
    );
    expect(body, contains('Plan: Basic'));
    expect(body, contains('Team size: Up to 5 users (\$30/month)'));
    expect(body, contains('Source: In-app (demo)'));
    expect(body, contains('Demo minutes left: 25'));
    expect(body, contains('Demo reference: abc123'));
  });
}
