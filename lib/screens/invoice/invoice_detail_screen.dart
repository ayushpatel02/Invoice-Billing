import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/invoice.dart';
import '../../providers/invoice_provider.dart';
import '../../providers/business_profile_provider.dart';
import '../../database/database_helper.dart';
import '../../services/pdf_service.dart';
import '../../widgets/summary_row.dart';
import '../../widgets/confirm_dialog.dart';
import '../../utils/currency_formatter.dart';
import '../../utils/date_formatter.dart';
import '../../utils/number_to_words.dart';
import '../../constants/app_theme.dart';
import '../payment/payment_dialog.dart';

class InvoiceDetailScreen extends StatefulWidget {
  final int invoiceId;
  final int customerId;

  const InvoiceDetailScreen({
    super.key,
    required this.invoiceId,
    required this.customerId,
  });

  @override
  State<InvoiceDetailScreen> createState() => _InvoiceDetailScreenState();
}

class _InvoiceDetailScreenState extends State<InvoiceDetailScreen> {
  Invoice? _invoice;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadInvoice();
  }

  Future<void> _loadInvoice() async {
    final inv =
        await DatabaseHelper.instance.getInvoiceById(widget.invoiceId);
    if (mounted) {
      setState(() {
        _invoice = inv;
        _loading = false;
      });
    }
  }

  Future<void> _downloadPdf() async {
    if (_invoice == null) return;
    final business =
        context.read<BusinessProfileProvider>().profile;
    if (business == null) return;

    final customer =
        await DatabaseHelper.instance.getCustomerById(widget.customerId);
    if (!mounted) return;
    if (customer == null) return;

    await PdfService.previewOrShare(
      business: business,
      customer: customer,
      invoice: _invoice!,
      lineItems: _invoice!.lineItems,
    );
  }

  Future<void> _markFullyPaid() async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Mark as Fully Paid',
      message:
          'Mark Invoice #${_invoice!.invoiceNo} as fully paid? The remaining balance will be forgiven.',
      confirmText: 'Mark Paid',
    );
    if (!confirmed || !mounted) return;

    final ok = await context
        .read<InvoiceProvider>()
        .markAsFullyPaid(widget.invoiceId);
    if (!mounted) return;
    if (ok) {
      await _loadInvoice();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invoice marked as fully paid')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Invoice')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_invoice == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Invoice')),
        body: const Center(child: Text('Invoice not found')),
      );
    }

    final inv = _invoice!;

    return Scaffold(
      appBar: AppBar(
        title: Text('Invoice #${inv.invoiceNo}'),
        actions: [
          IconButton(
            onPressed: _downloadPdf,
            icon: const Icon(Icons.picture_as_pdf),
            tooltip: 'Download PDF',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _Section(
            title: 'Invoice Details',
            children: [
              SummaryRow(
                  label: 'Invoice No.',
                  value: inv.invoiceNo.toString()),
              SummaryRow(
                  label: 'Date',
                  value: formatDisplayDate(inv.date)),
              SummaryRow(
                  label: 'Status',
                  value: _statusLabel(inv.status)),
            ],
          ),
          const SizedBox(height: 16),
          if (inv.lineItems.isNotEmpty) ...[
            const Text('Line Items',
                style: TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            _LineItemsTable(lineItems: inv.lineItems),
            const SizedBox(height: 16),
          ],
          _Section(
            title: 'Summary',
            children: [
              SummaryRow(
                  label: 'Subtotal',
                  value: formatCurrency(inv.totalAmount)),
              if (inv.cgstRate > 0)
                SummaryRow(
                    label: 'CGST (${inv.cgstRate}%)',
                    value: formatCurrency(inv.cgstAmount)),
              if (inv.sgstRate > 0)
                SummaryRow(
                    label: 'SGST (${inv.sgstRate}%)',
                    value: formatCurrency(inv.sgstAmount)),
              const Divider(),
              SummaryRow(
                  label: 'Net Payable',
                  value: formatCurrency(inv.netPayable),
                  isBold: true),
              if (inv.amountPaid > 0) ...[
                SummaryRow(
                    label: 'Amount Paid',
                    value: formatCurrency(inv.amountPaid)),
                SummaryRow(
                    label: 'Balance Due',
                    value: formatCurrency(inv.balance),
                    isBold: true,
                    valueColor:
                        inv.balance > 0 ? AppTheme.error : AppTheme.success),
              ],
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Amount in words:',
                    style: TextStyle(fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 4),
                Text(numberToWords(inv.netPayable),
                    style:
                        const TextStyle(fontStyle: FontStyle.italic)),
              ],
            ),
          ),
          if (inv.payments.isNotEmpty) ...[
            const SizedBox(height: 16),
            _Section(
              title: 'Payment History',
              children: inv.payments
                  .map((p) => SummaryRow(
                        label: formatDisplayDate(p.date),
                        value: formatCurrency(p.amount),
                      ))
                  .toList(),
            ),
          ],
          const SizedBox(height: 24),
          if (!inv.isFullyPaid)
            ElevatedButton.icon(
              onPressed: () => showPaymentDialog(
                context,
                invoice: inv,
                customerId: widget.customerId,
                onPaymentAdded: _loadInvoice,
              ),
              icon: const Icon(Icons.payment),
              label: const Text('Record Payment'),
              style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48)),
            ),
          if (inv.isPartiallyPaid) ...[
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _markFullyPaid,
              icon: const Icon(Icons.check_circle_outline,
                  color: AppTheme.success),
              label: const Text('Mark as Fully Paid',
                  style: TextStyle(color: AppTheme.success)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppTheme.success),
                minimumSize: const Size.fromHeight(48),
              ),
            ),
          ],
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'partially_paid':
        return 'Partially Paid';
      case 'fully_paid':
        return 'Fully Paid';
      default:
        return 'Unpaid';
    }
  }
}

class _Section extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _Section({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(
                fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: children),
          ),
        ),
      ],
    );
  }
}

class _LineItemsTable extends StatelessWidget {
  final List<dynamic> lineItems;

  const _LineItemsTable({required this.lineItems});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columnSpacing: 16,
          headingRowHeight: 36,
          dataRowMinHeight: 32,
          dataRowMaxHeight: 48,
          columns: const [
            DataColumn(label: Text('No.')),
            DataColumn(label: Text('Description')),
            DataColumn(label: Text('Qty'), numeric: true),
            DataColumn(label: Text('Rate'), numeric: true),
            DataColumn(label: Text('Amount'), numeric: true),
          ],
          rows: lineItems.map((item) {
            return DataRow(cells: [
              DataCell(Text(item.itemNo.toString())),
              DataCell(Text(item.description)),
              DataCell(Text(item.qty.toString())),
              DataCell(Text(formatAmount(item.rate))),
              DataCell(Text(formatAmount(item.amount))),
            ]);
          }).toList(),
        ),
      ),
    );
  }
}
