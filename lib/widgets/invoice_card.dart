import 'package:flutter/material.dart';
import '../models/invoice.dart';
import '../constants/app_theme.dart';
import '../utils/currency_formatter.dart';
import '../utils/date_formatter.dart';
import 'confirm_dialog.dart';

class InvoiceCard extends StatelessWidget {
  final Invoice invoice;
  final VoidCallback onTap;
  final VoidCallback? onEdit;
  final VoidCallback onDownload;
  final VoidCallback? onDelete;

  const InvoiceCard({
    super.key,
    required this.invoice,
    required this.onTap,
    this.onEdit,
    required this.onDownload,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final card = Card(
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
                      icon: const Icon(Icons.edit, size: 26),
                      tooltip: 'Edit',
                      padding: const EdgeInsets.all(4),
                      constraints: const BoxConstraints(),
                      color: AppTheme.secondary,
                    ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: onDownload,
                    icon: const Icon(Icons.picture_as_pdf, size: 24),
                    tooltip: 'Download PDF',
                    padding: const EdgeInsets.all(4),
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

    if (onDelete == null) return card;

    return Dismissible(
      key: ValueKey('invoice_${invoice.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.red[700],
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.delete_outline, color: Colors.white, size: 30),
            SizedBox(height: 4),
            Text('Delete',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold)),
          ],
        ),
      ),
      confirmDismiss: (_) => showConfirmDialog(
        context,
        title: 'Delete Invoice',
        message:
            'Delete Invoice #${invoice.invoiceNo}? This invoice and all its payment records will be permanently removed.',
        confirmText: 'Delete',
        isDangerous: true,
      ),
      onDismissed: (_) => onDelete!(),
      child: card,
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
