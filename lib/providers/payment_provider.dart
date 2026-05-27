import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/payment.dart';

class PaymentProvider extends ChangeNotifier {
  List<Payment> _payments = [];
  bool _isLoading = false;

  List<Payment> get payments => _payments;
  bool get isLoading => _isLoading;
  double get totalPaid =>
      _payments.fold(0.0, (sum, p) => sum + p.amount);

  Future<void> loadPayments(int invoiceId) async {
    _isLoading = true;
    notifyListeners();
    try {
      _payments =
          await DatabaseHelper.instance.getPaymentsByInvoice(invoiceId);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addPayment(
      Payment payment, double newAmountPaid, double netPayable) async {
    try {
      await DatabaseHelper.instance
          .insertPayment(payment, newAmountPaid, netPayable);
      await loadPayments(payment.invoiceId);
      return true;
    } catch (_) {
      return false;
    }
  }
}
