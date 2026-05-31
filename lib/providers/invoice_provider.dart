import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/invoice.dart';
import '../models/line_item.dart';

class InvoiceProvider extends ChangeNotifier {
  List<Invoice> _invoices = [];
  bool _isLoading = false;
  String? _error;
  int? _currentCustomerId;

  List<Invoice> get invoices => _invoices;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<Invoice> get unpaidInvoices =>
      _invoices.where((i) => i.isUnpaid).toList();
  List<Invoice> get partiallyPaidInvoices =>
      _invoices.where((i) => i.isPartiallyPaid).toList();
  List<Invoice> get fullyPaidInvoices =>
      _invoices.where((i) => i.isFullyPaid).toList();

  Future<void> loadInvoices(int customerId) async {
    _currentCustomerId = customerId;
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _invoices =
          await DatabaseHelper.instance.getInvoicesByCustomer(customerId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<int> getNextInvoiceNo(int customerId) async {
    return DatabaseHelper.instance.getNextInvoiceNo(customerId);
  }

  Future<Invoice?> getInvoiceById(int id) async {
    return DatabaseHelper.instance.getInvoiceById(id);
  }

  Future<bool> addInvoice(Invoice invoice, List<LineItem> items) async {
    try {
      await DatabaseHelper.instance.insertInvoice(invoice, items);
      if (_currentCustomerId != null) await loadInvoices(_currentCustomerId!);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> updateInvoice(Invoice invoice, List<LineItem> items) async {
    try {
      await DatabaseHelper.instance.updateInvoice(invoice, items);
      if (_currentCustomerId != null) await loadInvoices(_currentCustomerId!);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> markAsFullyPaid(int invoiceId) async {
    try {
      await DatabaseHelper.instance.markInvoiceFullyPaid(invoiceId);
      if (_currentCustomerId != null) await loadInvoices(_currentCustomerId!);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> deleteInvoice(int invoiceId) async {
    try {
      await DatabaseHelper.instance.deleteInvoice(invoiceId);
      if (_currentCustomerId != null) await loadInvoices(_currentCustomerId!);
      return true;
    } catch (_) {
      return false;
    }
  }
}
