import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/business_profile_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/customer_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final profileProvider =
        context.read<BusinessProfileProvider>();
    final settingsProvider = context.read<SettingsProvider>();
    final customerProvider = context.read<CustomerProvider>();

    await Future.wait([
      profileProvider.loadProfile(),
      settingsProvider.loadSettings(),
      customerProvider.loadCustomers(),
    ]);

    if (!mounted) return;

    if (profileProvider.hasProfile) {
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      Navigator.pushReplacementNamed(context, '/business-profile',
          arguments: {'isEdit': false});
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.receipt_long, size: 80, color: Color(0xFF1565C0)),
            SizedBox(height: 16),
            Text('Invoice Billing',
                style:
                    TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            SizedBox(height: 32),
            CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
