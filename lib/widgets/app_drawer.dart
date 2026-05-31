import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/business_profile_provider.dart';
import '../constants/app_theme.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final profile =
        context.watch<BusinessProfileProvider>().profile;

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              color: AppTheme.primary,
              gradient: LinearGradient(
                colors: [AppTheme.primary, Color(0xFFB71C1C)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(40),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.receipt_long,
                      color: Colors.white, size: 36),
                ),
                const SizedBox(height: 8),
                Text(
                  profile?.fullName ?? 'Invoice Billing',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
                ),
                if (profile?.phone.isNotEmpty ?? false)
                  Text(profile!.phone,
                      style: const TextStyle(
                          color: Colors.white70, fontSize: 12)),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Customers'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamedAndRemoveUntil(
                  context, '/home', (r) => false);
            },
          ),
          ListTile(
            leading: const Icon(Icons.business),
            title: const Text('Business Profile'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/business-profile',
                  arguments: {'isEdit': true});
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/settings');
            },
          ),
        ],
      ),
    );
  }
}
