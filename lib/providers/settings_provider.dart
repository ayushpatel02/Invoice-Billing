import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/app_settings.dart';

class SettingsProvider extends ChangeNotifier {
  AppSettings _settings = const AppSettings();
  bool _isLoading = false;

  AppSettings get settings => _settings;
  bool get isLoading => _isLoading;

  Future<void> loadSettings() async {
    _isLoading = true;
    notifyListeners();
    try {
      _settings = await DatabaseHelper.instance.getSettings();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> saveSettings(AppSettings settings) async {
    try {
      await DatabaseHelper.instance.updateSettings(settings);
      _settings = settings;
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }
}
