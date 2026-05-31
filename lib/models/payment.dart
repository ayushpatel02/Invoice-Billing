class Payment {
  final int? id;
  final int invoiceId;
  final double amount;
  final String date;
  final String createdAt;

  const Payment({
    this.id,
    required this.invoiceId,
    required this.amount,
    required this.date,
    required this.createdAt,
  });

  factory Payment.fromMap(Map<String, dynamic> map) => Payment(
        id: map['id'] as int?,
        invoiceId: map['invoice_id'] as int? ?? 0,
        amount: (map['amount'] as num?)?.toDouble() ?? 0,
        date: map['date'] as String? ?? '',
        createdAt: map['created_at'] as String? ?? '',
      );

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'invoice_id': invoiceId,
        'amount': amount,
        'date': date,
        'created_at': createdAt,
      };

  factory Payment.fromJson(Map<String, dynamic> json) =>
      Payment.fromMap(json);

  Map<String, dynamic> toJson() => toMap();

  Payment copyWith({
    int? id,
    int? invoiceId,
    double? amount,
    String? date,
    String? createdAt,
  }) =>
      Payment(
        id: id ?? this.id,
        invoiceId: invoiceId ?? this.invoiceId,
        amount: amount ?? this.amount,
        date: date ?? this.date,
        createdAt: createdAt ?? this.createdAt,
      );
}
