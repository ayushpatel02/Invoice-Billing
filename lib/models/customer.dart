class Customer {
  final int? id;
  final String firstName;
  final String middleName;
  final String lastName;
  final String address1;
  final String address2;
  final String address3;
  final String city;
  final String state;
  final String country;
  final String district;
  final String pinCode;
  final String phone;
  final String email;
  final String createdAt;
  final String updatedAt;
  final double outstandingBalance;

  const Customer({
    this.id,
    required this.firstName,
    this.middleName = '',
    required this.lastName,
    this.address1 = '',
    this.address2 = '',
    this.address3 = '',
    this.city = '',
    this.state = '',
    this.country = '',
    this.district = '',
    this.pinCode = '',
    this.phone = '',
    this.email = '',
    required this.createdAt,
    required this.updatedAt,
    this.outstandingBalance = 0,
  });

  String get fullName =>
      [firstName, middleName, lastName].where((s) => s.isNotEmpty).join(' ');

  String get fullAddress => [address1, address2, address3, city, state, country]
      .where((s) => s.isNotEmpty)
      .join(', ');

  factory Customer.fromMap(Map<String, dynamic> map) => Customer(
        id: map['id'] as int?,
        firstName: map['first_name'] as String? ?? '',
        middleName: map['middle_name'] as String? ?? '',
        lastName: map['last_name'] as String? ?? '',
        address1: map['address1'] as String? ?? '',
        address2: map['address2'] as String? ?? '',
        address3: map['address3'] as String? ?? '',
        city: map['city'] as String? ?? '',
        state: map['state'] as String? ?? '',
        country: map['country'] as String? ?? '',
        district: map['district'] as String? ?? '',
        pinCode: map['pin_code'] as String? ?? '',
        phone: map['phone'] as String? ?? '',
        email: map['email'] as String? ?? '',
        createdAt: map['created_at'] as String? ?? '',
        updatedAt: map['updated_at'] as String? ?? '',
        outstandingBalance:
            (map['outstanding_balance'] as num?)?.toDouble() ?? 0,
      );

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'first_name': firstName,
        'middle_name': middleName,
        'last_name': lastName,
        'address1': address1,
        'address2': address2,
        'address3': address3,
        'city': city,
        'state': state,
        'country': country,
        'district': district,
        'pin_code': pinCode,
        'phone': phone,
        'email': email,
        'created_at': createdAt,
        'updated_at': updatedAt,
      };

  factory Customer.fromJson(Map<String, dynamic> json) =>
      Customer.fromMap(json);

  Map<String, dynamic> toJson() => toMap();

  Customer copyWith({
    int? id,
    String? firstName,
    String? middleName,
    String? lastName,
    String? address1,
    String? address2,
    String? address3,
    String? city,
    String? state,
    String? country,
    String? district,
    String? pinCode,
    String? phone,
    String? email,
    String? createdAt,
    String? updatedAt,
    double? outstandingBalance,
  }) =>
      Customer(
        id: id ?? this.id,
        firstName: firstName ?? this.firstName,
        middleName: middleName ?? this.middleName,
        lastName: lastName ?? this.lastName,
        address1: address1 ?? this.address1,
        address2: address2 ?? this.address2,
        address3: address3 ?? this.address3,
        city: city ?? this.city,
        state: state ?? this.state,
        country: country ?? this.country,
        district: district ?? this.district,
        pinCode: pinCode ?? this.pinCode,
        phone: phone ?? this.phone,
        email: email ?? this.email,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        outstandingBalance: outstandingBalance ?? this.outstandingBalance,
      );
}
