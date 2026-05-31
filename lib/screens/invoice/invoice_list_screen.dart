import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/invoice.dart';
import '../../providers/invoice_provider.dart';
import '../../providers/business_profile_provider.dart';
import '../../database/database_helper.dart';
import '../../services/pdf_service.dart';
import '../../widgets/invoice_card.dart';
import '../../widgets/empty_state.dart';

class InvoiceListScreen extends StatefulWidget {
  final int customerId;
  final String customerName;

  const InvoiceListScreen({
    super.key,
    required this.customerId,
    required this.customerName,
  });

  @override
  State<InvoiceListScreen> createState() => _InvoiceListScreenState();
}

class _InvoiceListScreenState extends State<InvoiceListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<InvoiceProvider>().loadInvoices(widget.customerId);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _downloadPdf(Invoice invoice) async {
    final business =
        context.read<BusinessProfileProvider>().profile;
    if (business == null) return;

    final customer =
        await DatabaseHelper.instance.getCustomerById(widget.customerId);
    if (!mounted) return;
    if (customer == null) return;

    final fullInvoice =
        await DatabaseHelper.instance.getInvoiceById(invoice.id!);
    if (!mounted) return;
    if (fullInvoice == null) return;

    await PdfService.previewOrShare(
      business: business,
      customer: customer,
      invoice: fullInvoice,
      lineItems: fullInvoice.lineItems,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.customerName),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'Unpaid'),
            Tab(text: 'Partial'),
            Tab(text: 'Paid'),
          ],
        ),
      ),
      body: Consumer<InvoiceProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          return TabBarView(
            controller: _tabController,
            children: [
              _InvoiceTab(
                invoices: provider.unpaidInvoices,
                emptyMessage: 'No unpaid invoices',
                showEdit: true,
                onTap: (inv) => _openDetail(inv),
                onEdit: (inv) => _openForm(invoice: inv),
                onDownload: _downloadPdf,
                onDelete: _deleteInvoice,
              ),
              _InvoiceTab(
                invoices: provider.partiallyPaidInvoices,
                emptyMessage: 'No partially paid invoices',
                onTap: (inv) => _openDetail(inv),
                onDownload: _downloadPdf,
                onDelete: _deleteInvoice,
              ),
              _InvoiceTab(
                invoices: provider.fullyPaidInvoices,
                emptyMessage: 'No fully paid invoices',
                onTap: (inv) => _openDetail(inv),
                onDownload: _downloadPdf,
                onDelete: _deleteInvoice,
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openForm(),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _openDetail(Invoice invoice) {
    final provider = context.read<InvoiceProvider>();
    Navigator.pushNamed(
      context,
      '/invoice-detail',
      arguments: {
        'invoiceId': invoice.id,
        'customerId': widget.customerId,
      },
    ).then((_) {
      if (mounted) provider.loadInvoices(widget.customerId);
    });
  }

  void _openForm({Invoice? invoice}) {
    final provider = context.read<InvoiceProvider>();
    Navigator.pushNamed(
      context,
      '/invoice-form',
      arguments: {
        'customerId': widget.customerId,
        'invoice': invoice,
      },
    ).then((_) {
      if (mounted) provider.loadInvoices(widget.customerId);
    });
  }

  Future<void> _deleteInvoice(Invoice invoice) async {
    final provider = context.read<InvoiceProvider>();
    final ok = await provider.deleteInvoice(invoice.id!);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(ok
          ? 'Invoice #${invoice.invoiceNo} deleted'
          : 'Failed to delete invoice'),
    ));
  }
}

class _InvoiceTab extends StatelessWidget {
  final List<Invoice> invoices;
  final String emptyMessage;
  final bool showEdit;
  final void Function(Invoice) onTap;
  final void Function(Invoice)? onEdit;
  final void Function(Invoice) onDownload;
  final void Function(Invoice)? onDelete;

  const _InvoiceTab({
    required this.invoices,
    required this.emptyMessage,
    this.showEdit = false,
    required this.onTap,
    this.onEdit,
    required this.onDownload,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    if (invoices.isEmpty) {
      return EmptyState(
        icon: Icons.receipt_outlined,
        title: emptyMessage,
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: invoices.length,
      itemBuilder: (context, index) {
        final inv = invoices[index];
        return InvoiceCard(
          invoice: inv,
          onTap: () => onTap(inv),
          onEdit: showEdit && onEdit != null ? () => onEdit!(inv) : null,
          onDownload: () => onDownload(inv),
          onDelete: onDelete != null ? () => onDelete!(inv) : null,
        );
      },
    );
  }
}
