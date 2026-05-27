import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/customer.dart';

class CustomerProvider extends ChangeNotifier {
  List<Customer> _customers = [];
  bool _isLoading = false;
  String? _error;

  List<Customer> get customers => _customers;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadCustomers() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _customers = await DatabaseHelper.instance.getAllCustomers();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addCustomer(Customer customer) async {
    try {
      await DatabaseHelper.instance.insertCustomer(customer);
      await loadCustomers();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> updateCustomer(Customer customer) async {
    try {
      await DatabaseHelper.instance.updateCustomer(customer);
      await loadCustomers();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> deleteCustomer(int id) async {
    try {
      await DatabaseHelper.instance.deleteCustomer(id);
      await loadCustomers();
      return true;
    } catch (_) {
      return false;
    }
  }
}
