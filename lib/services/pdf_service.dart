import 'dart:io';
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/business_profile.dart';
import '../models/customer.dart';
import '../models/invoice.dart';
import '../models/line_item.dart';
import '../utils/currency_formatter.dart';
import '../utils/date_formatter.dart';
import '../utils/number_to_words.dart';

class PdfService {
  static Future<Uint8List> generateInvoicePdf({
    required BusinessProfile business,
    required Customer customer,
    required Invoice invoice,
    required List<LineItem> lineItems,
  }) async {
    final doc = pw.Document();
    final theme = pw.ThemeData.withFont(
      base: await PdfGoogleFonts.notoSansRegular(),
      bold: await PdfGoogleFonts.notoSansBold(),
    );

    pw.MemoryImage? logoImage;
    if (business.logoPath != null && File(business.logoPath!).existsSync()) {
      logoImage = pw.MemoryImage(
          await File(business.logoPath!).readAsBytes());
    }

    // Determine which optional columns have data
    final hasMM = lineItems.any((i) => i.mm != null);
    final hasHH = lineItems.any((i) => i.hh != null);
    final hasW = lineItems.any((i) => i.w != null);
    final hasNos = lineItems.any((i) => i.nos != null);

    doc.addPage(
      pw.MultiPage(
        theme: theme,
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(24),
        header: (_) => _buildHeader(business, customer, invoice, logoImage),
        footer: (_) => _buildFooter(),
        build: (ctx) => [
          pw.SizedBox(height: 12),
          _buildLineItemsTable(lineItems, hasMM, hasHH, hasW, hasNos),
          pw.SizedBox(height: 8),
          _buildTotals(invoice),
          pw.SizedBox(height: 8),
          _buildAmountInWords(invoice.netPayable),
          pw.SizedBox(height: 12),
          _buildTerms(),
          pw.SizedBox(height: 24),
          _buildSignatures(),
        ],
      ),
    );

    return doc.save();
  }

  static pw.Widget _buildHeader(BusinessProfile business, Customer customer,
      Invoice invoice, pw.MemoryImage? logo) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            if (logo != null)
              pw.Container(
                width: 56,
                height: 56,
                child: pw.Image(logo),
              ),
            pw.SizedBox(width: 12),
            pw.Expanded(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(business.fullName,
                      style: pw.TextStyle(
                          fontSize: 16, fontWeight: pw.FontWeight.bold)),
                  if (business.fullAddress.isNotEmpty)
                    pw.Text(business.fullAddress,
                        style: const pw.TextStyle(fontSize: 9)),
                  if (business.phone.isNotEmpty)
                    pw.Text('Phone: ${business.phone}',
                        style: const pw.TextStyle(fontSize: 9)),
                  if (business.email.isNotEmpty)
                    pw.Text('Email: ${business.email}',
                        style: const pw.TextStyle(fontSize: 9)),
                ],
              ),
            ),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Text('INVOICE',
                    style: pw.TextStyle(
                        fontSize: 18, fontWeight: pw.FontWeight.bold,
                        color: PdfColors.blue800)),
                pw.Text('No: ${invoice.invoiceNo}',
                    style: const pw.TextStyle(fontSize: 10)),
                pw.Text('Date: ${formatDisplayDate(invoice.date)}',
                    style: const pw.TextStyle(fontSize: 10)),
              ],
            ),
          ],
        ),
        pw.SizedBox(height: 8),
        pw.Divider(),
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('Bill To:',
                    style: pw.TextStyle(
                        fontSize: 10, fontWeight: pw.FontWeight.bold)),
                pw.Text(customer.fullName,
                    style: pw.TextStyle(
                        fontSize: 11, fontWeight: pw.FontWeight.bold)),
                if (customer.fullAddress.isNotEmpty)
                  pw.Text(customer.fullAddress,
                      style: const pw.TextStyle(fontSize: 9)),
                if (customer.phone.isNotEmpty)
                  pw.Text('Phone: ${customer.phone}',
                      style: const pw.TextStyle(fontSize: 9)),
                if (customer.email.isNotEmpty)
                  pw.Text('Email: ${customer.email}',
                      style: const pw.TextStyle(fontSize: 9)),
              ],
            ),
          ],
        ),
        pw.Divider(),
      ],
    );
  }

  static pw.Widget _buildLineItemsTable(List<LineItem> items, bool hasMM,
      bool hasHH, bool hasW, bool hasNos) {
    final headers = <String>['No.', 'Description'];
    if (hasMM) headers.add('MM');
    if (hasHH) headers.add('H');
    if (hasW) headers.add('W');
    if (hasNos) headers.add('Nos');
    headers.addAll(['Qty', 'Rate', 'Amount']);

    final data = items.map((item) {
      final row = <String>[
        item.itemNo.toString(),
        item.description,
      ];
      if (hasMM) row.add(item.mm?.toString() ?? '');
      if (hasHH) row.add(item.hh?.toString() ?? '');
      if (hasW) row.add(item.w?.toString() ?? '');
      if (hasNos) row.add(item.nos?.toString() ?? '');
      row.add(item.qty.toString());
      row.add(formatAmount(item.rate));
      row.add(formatAmount(item.amount));
      return row;
    }).toList();

    return pw.TableHelper.fromTextArray(
      headers: headers,
      data: data,
      border: pw.TableBorder.all(color: PdfColors.grey400),
      headerStyle: pw.TextStyle(
          fontWeight: pw.FontWeight.bold, fontSize: 9, color: PdfColors.white),
      headerDecoration:
          const pw.BoxDecoration(color: PdfColors.blue800),
      cellStyle: const pw.TextStyle(fontSize: 9),
      cellAlignments: {
        0: pw.Alignment.center,
        headers.length - 1: pw.Alignment.centerRight,
        headers.length - 2: pw.Alignment.centerRight,
        headers.length - 3: pw.Alignment.centerRight,
      },
    );
  }

  static pw.Widget _buildTotals(Invoice invoice) {
    return pw.Align(
      alignment: pw.Alignment.centerRight,
      child: pw.SizedBox(
        width: 220,
        child: pw.Column(
          children: [
            _totalRow('Subtotal', formatCurrency(invoice.totalAmount)),
            if (invoice.cgstRate > 0)
              _totalRow(
                  'CGST (${invoice.cgstRate}%)', formatCurrency(invoice.cgstAmount)),
            if (invoice.sgstRate > 0)
              _totalRow(
                  'SGST (${invoice.sgstRate}%)', formatCurrency(invoice.sgstAmount)),
            pw.Divider(thickness: 1),
            _totalRow('Net Payable', formatCurrency(invoice.netPayable),
                bold: true),
            if (invoice.amountPaid > 0) ...[
              _totalRow('Amount Paid', formatCurrency(invoice.amountPaid)),
              _totalRow('Balance Due', formatCurrency(invoice.balance),
                  bold: true, color: PdfColors.red800),
            ],
          ],
        ),
      ),
    );
  }

  static pw.Widget _totalRow(String label, String value,
      {bool bold = false, PdfColor? color}) {
    final style = bold
        ? pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)
        : const pw.TextStyle(fontSize: 10);
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(label, style: color != null ? pw.TextStyle(color: color, fontSize: 10) : style),
        pw.Text(value, style: color != null ? pw.TextStyle(color: color, fontSize: 10, fontWeight: pw.FontWeight.bold) : style),
      ],
    );
  }

  static pw.Widget _buildAmountInWords(double amount) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(8),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey400),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
      ),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('Amount in words: ',
              style: pw.TextStyle(
                  fontSize: 9, fontWeight: pw.FontWeight.bold)),
          pw.Expanded(
            child: pw.Text(numberToWords(amount),
                style: const pw.TextStyle(fontSize: 9)),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildTerms() {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Terms & Conditions:',
            style: pw.TextStyle(
                fontSize: 9, fontWeight: pw.FontWeight.bold)),
        pw.Text('1. Goods once sold will not be accepted.',
            style: const pw.TextStyle(fontSize: 8)),
        pw.Text('2. Payment due within 30 days.',
            style: const pw.TextStyle(fontSize: 8)),
      ],
    );
  }

  static pw.Widget _buildSignatures() {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Column(
          children: [
            pw.SizedBox(height: 32),
            pw.Container(
                width: 120, height: 1, color: PdfColors.black),
            pw.SizedBox(height: 4),
            pw.Text('Authorised Signatory',
                style: const pw.TextStyle(fontSize: 9)),
          ],
        ),
        pw.Column(
          children: [
            pw.SizedBox(height: 32),
            pw.Container(
                width: 120, height: 1, color: PdfColors.black),
            pw.SizedBox(height: 4),
            pw.Text('Receiver Signatory',
                style: const pw.TextStyle(fontSize: 9)),
          ],
        ),
      ],
    );
  }

  static pw.Widget _buildFooter() {
    return pw.Divider();
  }

  static Future<void> previewOrShare({
    required BusinessProfile business,
    required Customer customer,
    required Invoice invoice,
    required List<LineItem> lineItems,
  }) async {
    final bytes = await generateInvoicePdf(
      business: business,
      customer: customer,
      invoice: invoice,
      lineItems: lineItems,
    );
    await Printing.sharePdf(
      bytes: bytes,
      filename: 'invoice_${invoice.invoiceNo}.pdf',
    );
  }
}
