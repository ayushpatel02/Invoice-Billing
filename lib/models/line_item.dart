class LineItem {
  final int? id;
  final int? invoiceId;
  final int itemNo;
  final String description;
  final double? mm;
  final double? hh;
  final double? w;
  final double? nos;
  final double qty;
  final double rate;
  final double amount;

  const LineItem({
    this.id,
    this.invoiceId,
    required this.itemNo,
    required this.description,
    this.mm,
    this.hh,
    this.w,
    this.nos,
    required this.qty,
    required this.rate,
    required this.amount,
  });

  factory LineItem.fromMap(Map<String, dynamic> map) => LineItem(
        id: map['id'] as int?,
        invoiceId: map['invoice_id'] as int?,
        itemNo: map['item_no'] as int? ?? 0,
        description: map['description'] as String? ?? '',
        mm: (map['mm'] as num?)?.toDouble(),
        hh: (map['hh'] as num?)?.toDouble(),
        w: (map['w'] as num?)?.toDouble(),
        nos: (map['nos'] as num?)?.toDouble(),
        qty: (map['qty'] as num?)?.toDouble() ?? 0,
        rate: (map['rate'] as num?)?.toDouble() ?? 0,
        amount: (map['amount'] as num?)?.toDouble() ?? 0,
      );

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        if (invoiceId != null) 'invoice_id': invoiceId,
        'item_no': itemNo,
        'description': description,
        'mm': mm,
        'hh': hh,
        'w': w,
        'nos': nos,
        'qty': qty,
        'rate': rate,
        'amount': amount,
      };

  factory LineItem.fromJson(Map<String, dynamic> json) =>
      LineItem.fromMap(json);

  Map<String, dynamic> toJson() => toMap();

  LineItem copyWith({
    int? id,
    int? invoiceId,
    int? itemNo,
    String? description,
    double? mm,
    double? hh,
    double? w,
    double? nos,
    double? qty,
    double? rate,
    double? amount,
  }) =>
      LineItem(
        id: id ?? this.id,
        invoiceId: invoiceId ?? this.invoiceId,
        itemNo: itemNo ?? this.itemNo,
        description: description ?? this.description,
        mm: mm ?? this.mm,
        hh: hh ?? this.hh,
        w: w ?? this.w,
        nos: nos ?? this.nos,
        qty: qty ?? this.qty,
        rate: rate ?? this.rate,
        amount: amount ?? this.amount,
      );
}
