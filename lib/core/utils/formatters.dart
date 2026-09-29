import 'package:intl/intl.dart';

class Formatters {
  static final _currency = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
  static final _date = DateFormat('dd MMM yyyy', 'id_ID');
  static final _dateShort = DateFormat('dd/MM/yyyy');

  static String currency(double amount) => _currency.format(amount);
  static String date(DateTime d) => _date.format(d);
  static String dateShort(DateTime d) => _dateShort.format(d);

  static String compactCurrency(double amount) {
    if (amount >= 1000000000) return 'Rp ${(amount / 1000000000).toStringAsFixed(1)} M';
    if (amount >= 1000000) return 'Rp ${(amount / 1000000).toStringAsFixed(0)} Jt';
    if (amount >= 1000) return 'Rp ${(amount / 1000).toStringAsFixed(0)} Rb';
    return currency(amount);
  }
}
