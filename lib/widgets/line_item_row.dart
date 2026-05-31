import 'package:flutter/material.dart';
import '../models/line_item.dart';

class LineItemData {
  String description;
  String mm;
  String hh;
  String w;
  String nos;
  String qty;
  String rate;

  LineItemData({
    this.description = '',
    this.mm = '',
    this.hh = '',
    this.w = '',
    this.nos = '',
    this.qty = '',
    this.rate = '',
  });

  double get amount {
    final q = double.tryParse(qty) ?? 0;
    final r = double.tryParse(rate) ?? 0;
    return q * r;
  }

  LineItem toLineItem(int itemNo, {int? invoiceId}) => LineItem(
        invoiceId: invoiceId,
        itemNo: itemNo,
        description: description,
        mm: mm.isNotEmpty ? double.tryParse(mm) : null,
        hh: hh.isNotEmpty ? double.tryParse(hh) : null,
        w: w.isNotEmpty ? double.tryParse(w) : null,
        nos: nos.isNotEmpty ? double.tryParse(nos) : null,
        qty: double.tryParse(qty) ?? 0,
        rate: double.tryParse(rate) ?? 0,
        amount: amount,
      );

  factory LineItemData.fromLineItem(LineItem item) => LineItemData(
        description: item.description,
        mm: item.mm?.toString() ?? '',
        hh: item.hh?.toString() ?? '',
        w: item.w?.toString() ?? '',
        nos: item.nos?.toString() ?? '',
        qty: item.qty.toString(),
        rate: item.rate.toString(),
      );
}

class LineItemRow extends StatelessWidget {
  final int index;
  final LineItemData data;
  final VoidCallback onDelete;
  final VoidCallback onChanged;

  const LineItemRow({
    super.key,
    required this.index,
    required this.data,
    required this.onDelete,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 12,
                  backgroundColor: Colors.blueGrey,
                  child: Text('${index + 1}',
                      style: const TextStyle(
                          color: Colors.white, fontSize: 11)),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _field(
                    label: 'Description *',
                    initialValue: data.description,
                    onChanged: (v) {
                      data.description = v;
                      onChanged();
                    },
                  ),
                ),
                IconButton(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline,
                      color: Colors.red, size: 20),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _numField('MM', data.mm, (v) {
                  data.mm = v;
                  onChanged();
                }),
                _numField('H', data.hh, (v) {
                  data.hh = v;
                  onChanged();
                }),
                _numField('W', data.w, (v) {
                  data.w = v;
                  onChanged();
                }),
                _numField('Nos', data.nos, (v) {
                  data.nos = v;
                  onChanged();
                }),
                _numField('Qty *', data.qty, (v) {
                  data.qty = v;
                  onChanged();
                }),
                _numField('Rate *', data.rate, (v) {
                  data.rate = v;
                  onChanged();
                }),
                _amountDisplay(data.amount),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _field({
    required String label,
    required String initialValue,
    required ValueChanged<String> onChanged,
  }) {
    return TextFormField(
      initialValue: initialValue,
      decoration: InputDecoration(
        labelText: label,
        isDense: true,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        border: const OutlineInputBorder(),
      ),
      onChanged: onChanged,
    );
  }

  Widget _numField(
      String label, String initialValue, ValueChanged<String> onChanged) {
    return SizedBox(
      width: 72,
      child: TextFormField(
        initialValue: initialValue,
        decoration: InputDecoration(
          labelText: label,
          isDense: true,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          border: const OutlineInputBorder(),
        ),
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        onChanged: onChanged,
      ),
    );
  }

  Widget _amountDisplay(double amount) {
    return SizedBox(
      width: 90,
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: 'Amount',
          isDense: true,
          contentPadding:
              EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          border: OutlineInputBorder(),
          filled: true,
        ),
        child: Text(
          amount > 0 ? amount.toStringAsFixed(2) : '0.00',
          style: const TextStyle(fontSize: 14),
        ),
      ),
    );
  }
}
