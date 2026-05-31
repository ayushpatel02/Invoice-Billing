import 'package:intl/intl.dart';

final _inr = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 2);
final _plain = NumberFormat('#,##,##0.00', 'en_IN');

String formatCurrency(double amount) => _inr.format(amount);

String formatAmount(double amount) => _plain.format(amount);
