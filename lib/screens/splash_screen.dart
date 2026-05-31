import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/business_profile_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/customer_provider.dart';
import '../constants/app_theme.dart';

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
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppTheme.secondary,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(40),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(Icons.receipt_long,
                  color: Colors.white, size: 60),
            ),
            const SizedBox(height: 24),
            const Text('Invoice Billing',
                style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primary,
                    letterSpacing: 1.2)),
            const SizedBox(height: 8),
            const Text('Professional Invoicing',
                style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey)),
            const SizedBox(height: 40),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primary),
            ),
          ],
        ),
      ),
    );
  }
}
