import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/customer_provider.dart';
import '../../widgets/customer_card.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/app_drawer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CustomerProvider>().loadCustomers();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Customers'),
      ),
      drawer: const AppDrawer(),
      body: Consumer<CustomerProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (provider.customers.isEmpty) {
            return const EmptyState(
              icon: Icons.people_outline,
              title: 'No customers yet',
              subtitle: 'Tap + to add your first customer',
            );
          }
          return RefreshIndicator(
            onRefresh: provider.loadCustomers,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: provider.customers.length,
              itemBuilder: (context, index) {
                final customer = provider.customers[index];
                return CustomerCard(
                  customer: customer,
                  onTap: () => Navigator.pushNamed(
                    context,
                    '/invoice-list',
                    arguments: {
                      'customerId': customer.id,
                      'customerName': customer.fullName,
                    },
                  ).then((_) => provider.loadCustomers()),
                  onEdit: () => Navigator.pushNamed(
                    context,
                    '/customer-form',
                    arguments: {'customer': customer},
                  ).then((_) => provider.loadCustomers()),
                  onDelete: () async {
                    final confirmed = await showConfirmDialog(
                      context,
                      title: 'Delete Customer',
                      message:
                          'Delete ${customer.fullName}? All invoices and payments will be removed.',
                      confirmText: 'Delete',
                      isDangerous: true,
                    );
                    if (confirmed && context.mounted) {
                      final ok =
                          await provider.deleteCustomer(customer.id!);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(ok
                              ? 'Customer deleted'
                              : 'Failed to delete customer'),
                        ));
                      }
                    }
                  },
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final provider = context.read<CustomerProvider>();
          Navigator.pushNamed(
            context,
            '/customer-form',
            arguments: {'customer': null},
          ).then((_) {
            if (mounted) provider.loadCustomers();
          });
        },
        child: const Icon(Icons.person_add),
      ),
    );
  }
}
