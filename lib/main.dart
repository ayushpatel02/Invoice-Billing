import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app_router.dart';
import 'constants/app_theme.dart';
import 'database/database_helper.dart';
import 'providers/business_profile_provider.dart';
import 'providers/customer_provider.dart';
import 'providers/invoice_provider.dart';
import 'providers/payment_provider.dart';
import 'providers/settings_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseHelper.instance.database;
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => BusinessProfileProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(create: (_) => CustomerProvider()),
        ChangeNotifierProvider(create: (_) => InvoiceProvider()),
        ChangeNotifierProvider(create: (_) => PaymentProvider()),
      ],
      child: MaterialApp(
        title: 'Invoice Billing',
        theme: AppTheme.lightTheme,
        onGenerateRoute: AppRouter.onGenerateRoute,
        initialRoute: '/splash',
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
