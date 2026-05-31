import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/settings_provider.dart';
import '../../providers/business_profile_provider.dart';
import '../../providers/customer_provider.dart';
import '../../services/export_import_service.dart';
import '../../widgets/confirm_dialog.dart';
import '../../utils/validators.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _cgstController;
  late TextEditingController _sgstController;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final settings = context.read<SettingsProvider>().settings;
    _cgstController =
        TextEditingController(text: settings.cgstRate.toString());
    _sgstController =
        TextEditingController(text: settings.sgstRate.toString());
  }

  @override
  void dispose() {
    _cgstController.dispose();
    _sgstController.dispose();
    super.dispose();
  }

  Future<void> _saveSettings() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final settings =
        context.read<SettingsProvider>().settings.copyWith(
              cgstRate: double.parse(_cgstController.text.trim()),
              sgstRate: double.parse(_sgstController.text.trim()),
            );

    final ok =
        await context.read<SettingsProvider>().saveSettings(settings);
    if (!mounted) return;
    setState(() => _saving = false);

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(
          ok ? 'Settings saved' : 'Failed to save settings'),
    ));
  }

  Future<void> _export() async {
    final ok = await ExportImportService.exportData();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(ok ? 'Export successful' : 'Export failed'),
    ));
  }

  Future<void> _import() async {
    final data = await ExportImportService.pickImportFile();
    if (data == null || !mounted) return;

    final confirmed = await showConfirmDialog(
      context,
      title: 'Import Data',
      message:
          'This will replace ALL current data with the backup. This cannot be undone.',
      confirmText: 'Import',
      isDangerous: true,
    );
    if (!confirmed || !mounted) return;

    final ok = await ExportImportService.importData(data);
    if (!mounted) return;

    if (ok) {
      await Future.wait([
        context.read<BusinessProfileProvider>().loadProfile(),
        context.read<SettingsProvider>().loadSettings(),
        context.read<CustomerProvider>().loadCustomers(),
      ]);
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content:
          Text(ok ? 'Data imported successfully' : 'Import failed'),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Tax Configuration',
              style: TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 12),
          Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _cgstController,
                  decoration: const InputDecoration(
                    labelText: 'CGST Rate (%)',
                    suffixText: '%',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(
                      decimal: true),
                  validator: nonNegativeNumber,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _sgstController,
                  decoration: const InputDecoration(
                    labelText: 'SGST Rate (%)',
                    suffixText: '%',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(
                      decimal: true),
                  validator: nonNegativeNumber,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _saving ? null : _saveSettings,
                  style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(48)),
                  child: _saving
                      ? const CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2)
                      : const Text('Save Tax Rates'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 16),
          const Text('Data Backup',
              style: TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: _export,
            icon: const Icon(Icons.upload),
            label: const Text('Export Data (JSON)'),
            style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(48)),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: _import,
            icon: const Icon(Icons.download),
            label: const Text('Import Data (JSON)'),
            style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(48)),
          ),
        ],
      ),
    );
  }
}
