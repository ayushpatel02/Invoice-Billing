import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/invoice.dart';
import '../../models/payment.dart';
import '../../providers/payment_provider.dart';
import '../../providers/invoice_provider.dart';
import '../../providers/customer_provider.dart';
import '../../utils/currency_formatter.dart';
import '../../utils/date_formatter.dart';
import '../../utils/validators.dart';

Future<void> showPaymentDialog(
  BuildContext context, {
  required Invoice invoice,
  required int customerId,
  required VoidCallback onPaymentAdded,
}) async {
  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (ctx) => MultiProvider(
      providers: [
        ChangeNotifierProvider.value(
            value: context.read<PaymentProvider>()),
        ChangeNotifierProvider.value(
            value: context.read<InvoiceProvider>()),
        ChangeNotifierProvider.value(
            value: context.read<CustomerProvider>()),
      ],
      child: _PaymentForm(
        invoice: invoice,
        customerId: customerId,
        onPaymentAdded: onPaymentAdded,
      ),
    ),
  );
}

class _PaymentForm extends StatefulWidget {
  final Invoice invoice;
  final int customerId;
  final VoidCallback onPaymentAdded;

  const _PaymentForm({
    required this.invoice,
    required this.customerId,
    required this.onPaymentAdded,
  });

  @override
  State<_PaymentForm> createState() => _PaymentFormState();
}

class _PaymentFormState extends State<_PaymentForm> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  String _date = todayIso();
  bool _saving = false;

  double get _balance => widget.invoice.balance;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

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

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final amount =
        double.parse(_amountController.text.trim());
    final now = todayIso();
    final payment = Payment(
      invoiceId: widget.invoice.id!,
      amount: amount,
      date: _date,
      createdAt: now,
    );

    final newAmountPaid = widget.invoice.amountPaid + amount;
    final ok = await context.read<PaymentProvider>().addPayment(
          payment,
          newAmountPaid,
          widget.invoice.netPayable,
        );

    if (!mounted) return;
    setState(() => _saving = false);

    if (ok) {
      final invoiceProvider = context.read<InvoiceProvider>();
      final customerProvider = context.read<CustomerProvider>();
      await invoiceProvider.loadInvoices(widget.customerId);
      if (!mounted) return;
      await customerProvider.loadCustomers();
      if (!mounted) return;
      widget.onPaymentAdded();
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Payment recorded')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to record payment')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Record Payment – Invoice #${widget.invoice.invoiceNo}',
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Net Payable'),
                Text(formatCurrency(widget.invoice.netPayable),
                    style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            if (widget.invoice.amountPaid > 0)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Already Paid'),
                  Text(formatCurrency(widget.invoice.amountPaid)),
                ],
              ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Balance Due'),
                Text(
                  formatCurrency(_balance),
                  style: const TextStyle(
                      color: Colors.red, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _amountController,
              decoration: const InputDecoration(
                labelText: 'Payment Amount *',
                prefixText: '₹ ',
                border: OutlineInputBorder(),
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              autofocus: true,
              validator: (value) {
                final err = positiveNumber(value);
                if (err != null) return err;
                final amount = double.tryParse(value!.trim()) ?? 0;
                if (amount > _balance) {
                  return 'Cannot exceed balance of ${formatCurrency(_balance)}';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            InkWell(
              onTap: _pickDate,
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Payment Date',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.calendar_today, size: 18),
                ),
                child: Text(formatDisplayDate(_date)),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _saving ? null : _submit,
              style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48)),
              child: _saving
                  ? const CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2)
                  : const Text('Save Payment'),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
