import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/invoice.dart';
import '../../providers/invoice_provider.dart';
import '../../providers/settings_provider.dart';
import '../../widgets/line_item_row.dart';
import '../../widgets/summary_row.dart';
import '../../utils/currency_formatter.dart';
import '../../utils/date_formatter.dart';
import '../../utils/number_to_words.dart';

class InvoiceFormScreen extends StatefulWidget {
  final int customerId;
  final Invoice? invoice;

  const InvoiceFormScreen({
    super.key,
    required this.customerId,
    this.invoice,
  });

  @override
  State<InvoiceFormScreen> createState() => _InvoiceFormScreenState();
}

class _InvoiceFormScreenState extends State<InvoiceFormScreen> {
  bool _loading = true;
  bool _saving = false;
  int _invoiceNo = 1;
  String _date = todayIso();
  final List<LineItemData> _lineItems = [];

  bool get isEdit => widget.invoice != null;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final provider = context.read<InvoiceProvider>();

    if (isEdit) {
      _invoiceNo = widget.invoice!.invoiceNo;
      _date = widget.invoice!.date;
      final full =
          await provider.getInvoiceById(widget.invoice!.id!);
      if (full != null) {
        for (final item in full.lineItems) {
          _lineItems.add(LineItemData.fromLineItem(item));
        }
      }
    } else {
      _invoiceNo = await provider.getNextInvoiceNo(widget.customerId);
      _lineItems.add(LineItemData());
    }

    if (mounted) setState(() => _loading = false);
  }

  double get _total =>
      _lineItems.fold(0, (sum, item) => sum + item.amount);

  double get _cgstRate =>
      context.read<SettingsProvider>().settings.cgstRate;

  double get _sgstRate =>
      context.read<SettingsProvider>().settings.sgstRate;

  double get _cgstAmount => _total * _cgstRate / 100;
  double get _sgstAmount => _total * _sgstRate / 100;
  double get _netPayable => _total + _cgstAmount + _sgstAmount;

  Future<void> _pickDate() async {
    final initial = parseIsoDate(_date) ?? DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && mounted) {
      setState(() => _date = dateToIso(picked));
    }
  }

  Future<void> _save() async {
    if (_lineItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add at least one line item')),
      );
      return;
    }

    for (final item in _lineItems) {
      if (item.description.isEmpty ||
          (double.tryParse(item.qty) ?? 0) <= 0 ||
          (double.tryParse(item.rate) ?? 0) <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content:
                  Text('Each item needs Description, Qty, and Rate')),
        );
        return;
      }
    }

    setState(() => _saving = true);

    final now = todayIso();
    final cgst = _cgstRate;
    final sgst = _sgstRate;

    final invoice = Invoice(
      id: widget.invoice?.id,
      customerId: widget.customerId,
      invoiceNo: _invoiceNo,
      date: _date,
      totalAmount: _total,
      cgstRate: cgst,
      sgstRate: sgst,
      cgstAmount: _cgstAmount,
      sgstAmount: _sgstAmount,
      netPayable: _netPayable,
      amountPaid: widget.invoice?.amountPaid ?? 0,
      status: widget.invoice?.status ?? 'unpaid',
      createdAt: widget.invoice?.createdAt ?? now,
      updatedAt: now,
    );

    final items = _lineItems
        .asMap()
        .entries
        .map((e) => e.value.toLineItem(e.key + 1,
            invoiceId: widget.invoice?.id))
        .toList();

    final provider = context.read<InvoiceProvider>();
    final success = isEdit
        ? await provider.updateInvoice(invoice, items)
        : await provider.addInvoice(invoice, items);

    if (!mounted) return;
    setState(() => _saving = false);

    if (success) {
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to save invoice')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        appBar: AppBar(
            title:
                Text(isEdit ? 'Edit Invoice' : 'New Invoice')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit
            ? 'Edit Invoice #$_invoiceNo'
            : 'New Invoice #$_invoiceNo'),
        actions: [
          TextButton(
            onPressed: _saving ? null : _save,
            child: _saving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white))
                : const Text('Save',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(children: [
            Expanded(
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Invoice No.',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                child: Text('$_invoiceNo',
                    style: const TextStyle(fontSize: 16)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: InkWell(
                onTap: _pickDate,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Date',
                    border: OutlineInputBorder(),
                    isDense: true,
                    suffixIcon: Icon(Icons.calendar_today, size: 18),
                  ),
                  child: Text(formatDisplayDate(_date)),
                ),
              ),
            ),
          ]),
          const SizedBox(height: 20),
          const Text('Line Items',
              style:
                  TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          ...List.generate(
            _lineItems.length,
            (i) => LineItemRow(
              key: ValueKey(i),
              index: i,
              data: _lineItems[i],
              onDelete: () => setState(() => _lineItems.removeAt(i)),
              onChanged: () => setState(() {}),
            ),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () =>
                setState(() => _lineItems.add(LineItemData())),
            icon: const Icon(Icons.add),
            label: const Text('Add Line Item'),
          ),
          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 8),
          SummaryRow(label: 'Subtotal', value: formatCurrency(_total)),
          if (_cgstRate > 0)
            SummaryRow(
                label: 'CGST ($_cgstRate%)',
                value: formatCurrency(_cgstAmount)),
          if (_sgstRate > 0)
            SummaryRow(
                label: 'SGST ($_sgstRate%)',
                value: formatCurrency(_sgstAmount)),
          const Divider(),
          SummaryRow(
              label: 'Net Payable',
              value: formatCurrency(_netPayable),
              isBold: true),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Amount in words:',
                    style: TextStyle(
                        fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 4),
                Text(numberToWords(_netPayable),
                    style: const TextStyle(
                        fontStyle: FontStyle.italic)),
              ],
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
