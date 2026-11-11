import 'package:flutter_test/flutter_test.dart';
import 'package:inventory_management_system/config/currency_config.dart';

void main() {
  test('shillings keep their format', () {
    expect(AppCurrency.code, 'KES');
    expect(AppCurrency.format(0), 'KES 0');
    expect(AppCurrency.format(185), 'KES 185');
    expect(AppCurrency.format(1450), 'KES 1,450');
    expect(AppCurrency.format(1450.5), 'KES 1,450.50');
    expect(AppCurrency.format(3000000), 'KES 3,000,000');
    expect(AppCurrency.format(1234567), 'KES 1,234,567');
  });

  test('dollar equivalents use the display rate', () {
    expect(AppCurrency.usd(130), '\$1.00');
    expect(AppCurrency.usd(185), '\$1.42');
    expect(AppCurrency.usd(1450), '\$11.15');
    expect(AppCurrency.usd(5200), '\$40.00');
    expect(AppCurrency.usd(130000), '\$1,000');
  });

  test('both currencies show together', () {
    expect(AppCurrency.formatBoth(185), 'KES 185 (\$1.42)');
    expect(AppCurrency.formatBoth(0), 'KES 0 (\$0.00)');
  });
}
