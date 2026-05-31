import 'line_item.dart';
import 'payment.dart';

class Invoice {
  final int? id;
  final int customerId;
  final int invoiceNo;
  final String date;
  final double totalAmount;
  final double cgstRate;
  final double sgstRate;
  final double cgstAmount;
  final double sgstAmount;
  final double netPayable;
  final double amountPaid;
  final String status;
  final String createdAt;
  final String updatedAt;
  final List<LineItem> lineItems;
  final List<Payment> payments;

  const Invoice({
    this.id,
    required this.customerId,
    required this.invoiceNo,
    required this.date,
    this.totalAmount = 0,
    this.cgstRate = 0,
    this.sgstRate = 0,
    this.cgstAmount = 0,
    this.sgstAmount = 0,
    this.netPayable = 0,
    this.amountPaid = 0,
    this.status = 'unpaid',
    required this.createdAt,
    required this.updatedAt,
    this.lineItems = const [],
    this.payments = const [],
  });

  double get balance => netPayable - amountPaid;
  bool get isEditable => status == 'unpaid';
  bool get isUnpaid => status == 'unpaid';
  bool get isPartiallyPaid => status == 'partially_paid';
  bool get isFullyPaid => status == 'fully_paid';

  factory Invoice.fromMap(Map<String, dynamic> map) => Invoice(
        id: map['id'] as int?,
        customerId: map['customer_id'] as int? ?? 0,
        invoiceNo: map['invoice_no'] as int? ?? 0,
        date: map['date'] as String? ?? '',
        totalAmount: (map['total_amount'] as num?)?.toDouble() ?? 0,
        cgstRate: (map['cgst_rate'] as num?)?.toDouble() ?? 0,
        sgstRate: (map['sgst_rate'] as num?)?.toDouble() ?? 0,
        cgstAmount: (map['cgst_amount'] as num?)?.toDouble() ?? 0,
        sgstAmount: (map['sgst_amount'] as num?)?.toDouble() ?? 0,
        netPayable: (map['net_payable'] as num?)?.toDouble() ?? 0,
        amountPaid: (map['amount_paid'] as num?)?.toDouble() ?? 0,
        status: map['status'] as String? ?? 'unpaid',
        createdAt: map['created_at'] as String? ?? '',
        updatedAt: map['updated_at'] as String? ?? '',
      );

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'customer_id': customerId,
        'invoice_no': invoiceNo,
        'date': date,
        'total_amount': totalAmount,
        'cgst_rate': cgstRate,
        'sgst_rate': sgstRate,
        'cgst_amount': cgstAmount,
        'sgst_amount': sgstAmount,
        'net_payable': netPayable,
        'amount_paid': amountPaid,
        'status': status,
        'created_at': createdAt,
        'updated_at': updatedAt,
      };

  factory Invoice.fromJson(Map<String, dynamic> json) {
    final inv = Invoice.fromMap(json);
    final items = (json['line_items'] as List<dynamic>?)
            ?.map((e) => LineItem.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];
    final pays = (json['payments'] as List<dynamic>?)
            ?.map((e) => Payment.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];
    return inv.copyWith(lineItems: items, payments: pays);
  }

  Map<String, dynamic> toJson() => {
        ...toMap(),
        'line_items': lineItems.map((e) => e.toJson()).toList(),
        'payments': payments.map((e) => e.toJson()).toList(),
      };

  Invoice copyWith({
    int? id,
    int? customerId,
    int? invoiceNo,
    String? date,
    double? totalAmount,
    double? cgstRate,
    double? sgstRate,
    double? cgstAmount,
    double? sgstAmount,
    double? netPayable,
    double? amountPaid,
    String? status,
    String? createdAt,
    String? updatedAt,
    List<LineItem>? lineItems,
    List<Payment>? payments,
  }) =>
      Invoice(
        id: id ?? this.id,
        customerId: customerId ?? this.customerId,
        invoiceNo: invoiceNo ?? this.invoiceNo,
        date: date ?? this.date,
        totalAmount: totalAmount ?? this.totalAmount,
        cgstRate: cgstRate ?? this.cgstRate,
        sgstRate: sgstRate ?? this.sgstRate,
        cgstAmount: cgstAmount ?? this.cgstAmount,
        sgstAmount: sgstAmount ?? this.sgstAmount,
        netPayable: netPayable ?? this.netPayable,
        amountPaid: amountPaid ?? this.amountPaid,
        status: status ?? this.status,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        lineItems: lineItems ?? this.lineItems,
        payments: payments ?? this.payments,
      );
}
