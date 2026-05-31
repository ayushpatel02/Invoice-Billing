import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'screens/business_profile/business_profile_form_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/customer/customer_form_screen.dart';
import 'screens/invoice/invoice_list_screen.dart';
import 'screens/invoice/invoice_form_screen.dart';
import 'screens/invoice/invoice_detail_screen.dart';
import 'screens/settings/settings_screen.dart';
import 'models/customer.dart';
import 'models/invoice.dart';

class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/splash':
        return _route(const SplashScreen());

      case '/business-profile':
        final args = settings.arguments as Map<String, dynamic>? ?? {};
        return _route(BusinessProfileFormScreen(
            isEdit: args['isEdit'] as bool? ?? true));

      case '/home':
        return _route(const HomeScreen());

      case '/customer-form':
        final args = settings.arguments as Map<String, dynamic>? ?? {};
        return _route(
            CustomerFormScreen(customer: args['customer'] as Customer?));

      case '/invoice-list':
        final args = settings.arguments as Map<String, dynamic>;
        return _route(InvoiceListScreen(
          customerId: args['customerId'] as int,
          customerName: args['customerName'] as String,
        ));

      case '/invoice-form':
        final args = settings.arguments as Map<String, dynamic>;
        return _route(InvoiceFormScreen(
          customerId: args['customerId'] as int,
          invoice: args['invoice'] as Invoice?,
        ));

      case '/invoice-detail':
        final args = settings.arguments as Map<String, dynamic>;
        return _route(InvoiceDetailScreen(
          invoiceId: args['invoiceId'] as int,
          customerId: args['customerId'] as int,
        ));

      case '/settings':
        return _route(const SettingsScreen());

      default:
        return _route(const HomeScreen());
    }
  }

  static MaterialPageRoute<T> _route<T>(Widget widget) =>
      MaterialPageRoute(builder: (_) => widget);
}
