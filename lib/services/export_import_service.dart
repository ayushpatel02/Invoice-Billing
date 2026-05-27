import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart' show Share, XFile;
import '../database/database_helper.dart';
import '../utils/date_formatter.dart';

class ExportImportService {
  static Future<bool> exportData() async {
    try {
      final data = await DatabaseHelper.instance.exportAllData();
      final json = const JsonEncoder.withIndent('  ').convert(data);
      final dir = await getTemporaryDirectory();
      final fileName =
          'invoice_backup_${todayIso().replaceAll('-', '')}.json';
      final file = File('${dir.path}/$fileName');
      await file.writeAsString(json);
      await Share.shareXFiles(
        [XFile(file.path)],
        subject: 'Invoice Billing Backup',
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  static Future<Map<String, dynamic>?> pickImportFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );
      if (result == null || result.files.single.path == null) return null;
      final content = await File(result.files.single.path!).readAsString();
      return jsonDecode(content) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  static Future<bool> importData(Map<String, dynamic> data) async {
    try {
      await DatabaseHelper.instance.importAllData(data);
      return true;
    } catch (_) {
      return false;
    }
  }
}
