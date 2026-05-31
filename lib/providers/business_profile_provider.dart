import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/business_profile.dart';

class BusinessProfileProvider extends ChangeNotifier {
  BusinessProfile? _profile;
  bool _isLoading = false;

  BusinessProfile? get profile => _profile;
  bool get isLoading => _isLoading;
  bool get hasProfile => _profile != null;

  Future<void> loadProfile() async {
    _isLoading = true;
    notifyListeners();
    try {
      _profile = await DatabaseHelper.instance.getBusinessProfile();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> saveProfile(BusinessProfile profile) async {
    try {
      await DatabaseHelper.instance.saveBusinessProfile(profile);
      _profile = profile.copyWith(id: 1);
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }
}
