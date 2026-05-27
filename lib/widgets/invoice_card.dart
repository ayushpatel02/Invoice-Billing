import 'package:flutter/material.dart';
import '../models/invoice.dart';
import '../constants/app_theme.dart';
import '../utils/currency_formatter.dart';
import '../utils/date_formatter.dart';

class InvoiceCard extends StatelessWidget {
  final Invoice invoice;
  final VoidCallback onTap;
  final VoidCallback? onEdit;
  final VoidCallback onDownload;

  const InvoiceCard({
    super.key,
    required this.invoice,
    required this.onTap,
    this.onEdit,
    required this.onDownload,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Invoice #${invoice.invoiceNo}',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 15)),
                  _StatusChip(status: invoice.status),
                ],
              ),
              const SizedBox(height: 4),
              Text(formatDisplayDate(invoice.date),
                  style: TextStyle(color: Colors.grey[600], fontSize: 12)),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Net Payable',
                          style: TextStyle(
                              fontSize: 11, color: Colors.grey[500])),
                      Text(formatCurrency(invoice.netPayable),
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  if (!invoice.isUnpaid)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('Balance',
                            style: TextStyle(
                                fontSize: 11, color: Colors.grey[500])),
                        Text(
                          formatCurrency(invoice.balance),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: invoice.balance > 0
                                ? AppTheme.error
                                : AppTheme.success,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (onEdit != null)
                    IconButton(
                      onPressed: onEdit,
                      icon: const Icon(Icons.edit, size: 20),
                      tooltip: 'Edit',
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      color: Colors.blueGrey,
                    ),
                  const SizedBox(width: 12),
                  IconButton(
                    onPressed: onDownload,
                    icon: const Icon(Icons.picture_as_pdf, size: 20),
                    tooltip: 'Download PDF',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    color: AppTheme.primary,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String status;
  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;
    switch (status) {
      case 'partially_paid':
        color = AppTheme.warning;
        label = 'Partial';
      case 'fully_paid':
        color = AppTheme.success;
        label = 'Paid';
      default:
        color = AppTheme.error;
        label = 'Unpaid';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(30),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withAlpha(100)),
      ),
      child: Text(label,
          style: TextStyle(
              color: color, fontSize: 11, fontWeight: FontWeight.bold)),
    );
  }
}
