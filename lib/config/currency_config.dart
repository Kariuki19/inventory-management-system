import 'package:intl/intl.dart';

class AppCurrency {
  static const String code = 'KES';
  static const String prefix = 'KES ';

  /// Shillings per US dollar, used only to show the dollar equivalent.
  /// It is a fixed display rate: update it when the rate changes.
  static const double kesPerUsd = 130;

  static final NumberFormat _whole = NumberFormat('#,##0');
  static final NumberFormat _cents = NumberFormat('#,##0.00');

  /// Shillings only, e.g. KES 1,450 or KES 1,450.50.
  static String format(num value) {
    var v = value.toDouble();
    if (!v.isFinite) v = 0;
    final isWhole = v == v.roundToDouble();
    return '$prefix${isWhole ? _whole.format(v.toInt()) : _cents.format(v)}';
  }

  /// Dollar equivalent of an amount in shillings, e.g. $11.15.
  /// From $1,000 upwards the cents are dropped.
  static String usd(num kes) {
    var dollars = kes.toDouble() / kesPerUsd;
    if (!dollars.isFinite) dollars = 0;
    final text = dollars.abs() >= 1000
        ? _whole.format(dollars.round())
        : _cents.format(dollars);
    return '\$$text';
  }

  /// Both currencies, e.g. KES 1,450 ($11.15).
  static String formatBoth(num kes) => '${format(kes)} (${usd(kes)})';
}
