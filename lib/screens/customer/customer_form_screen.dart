import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/customer.dart';
import '../../providers/customer_provider.dart';
import '../../utils/validators.dart';
import '../../utils/date_formatter.dart';

class CustomerFormScreen extends StatefulWidget {
  final Customer? customer;

  const CustomerFormScreen({super.key, this.customer});

  @override
  State<CustomerFormScreen> createState() => _CustomerFormScreenState();
}

class _CustomerFormScreenState extends State<CustomerFormScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _saving = false;

  final _firstName = TextEditingController();
  final _middleName = TextEditingController();
  final _lastName = TextEditingController();
  final _address1 = TextEditingController();
  final _address2 = TextEditingController();
  final _address3 = TextEditingController();
  final _city = TextEditingController();
  final _state = TextEditingController();
  final _country = TextEditingController();
  final _district = TextEditingController();
  final _pinCode = TextEditingController();
  final _phone = TextEditingController();
  final _email = TextEditingController();

  bool get isEdit => widget.customer != null;

  @override
  void initState() {
    super.initState();
    if (isEdit) _populateFrom(widget.customer!);
  }

  void _populateFrom(Customer c) {
    _firstName.text = c.firstName;
    _middleName.text = c.middleName;
    _lastName.text = c.lastName;
    _address1.text = c.address1;
    _address2.text = c.address2;
    _address3.text = c.address3;
    _city.text = c.city;
    _state.text = c.state;
    _country.text = c.country;
    _district.text = c.district;
    _pinCode.text = c.pinCode;
    _phone.text = c.phone;
    _email.text = c.email;
  }

  @override
  void dispose() {
    for (final c in [
      _firstName, _middleName, _lastName, _address1, _address2, _address3,
      _city, _state, _country, _district, _pinCode, _phone, _email
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final now = todayIso();
    final customer = Customer(
      id: widget.customer?.id,
      firstName: _firstName.text.trim(),
      middleName: _middleName.text.trim(),
      lastName: _lastName.text.trim(),
      address1: _address1.text.trim(),
      address2: _address2.text.trim(),
      address3: _address3.text.trim(),
      city: _city.text.trim(),
      state: _state.text.trim(),
      country: _country.text.trim(),
      district: _district.text.trim(),
      pinCode: _pinCode.text.trim(),
      phone: _phone.text.trim(),
      email: _email.text.trim(),
      createdAt: widget.customer?.createdAt ?? now,
      updatedAt: now,
    );

    final provider = context.read<CustomerProvider>();
    final success = isEdit
        ? await provider.updateCustomer(customer)
        : await provider.addCustomer(customer);

    if (!mounted) return;
    setState(() => _saving = false);

    if (success) {
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to save customer')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Customer' : 'New Customer'),
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
                        color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(children: [
              Expanded(
                  child: _tf('First Name *', _firstName,
                      validator: requiredField)),
              const SizedBox(width: 8),
              Expanded(child: _tf('Middle Name', _middleName)),
            ]),
            const SizedBox(height: 12),
            _tf('Last Name *', _lastName, validator: requiredField),
            const SizedBox(height: 12),
            _tf('Address Line 1', _address1),
            const SizedBox(height: 12),
            _tf('Address Line 2', _address2),
            const SizedBox(height: 12),
            _tf('Address Line 3', _address3),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: _tf('City', _city)),
              const SizedBox(width: 8),
              Expanded(child: _tf('District', _district)),
            ]),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: _tf('State', _state)),
              const SizedBox(width: 8),
              Expanded(child: _tf('Country', _country)),
            ]),
            const SizedBox(height: 12),
            _tf('Pin Code', _pinCode, keyboardType: TextInputType.number),
            const SizedBox(height: 12),
            _tf('Phone Number', _phone,
                keyboardType: TextInputType.phone,
                validator: validPhone),
            const SizedBox(height: 12),
            _tf('Email', _email,
                keyboardType: TextInputType.emailAddress,
                validator: validEmail),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _tf(
    String label,
    TextEditingController controller, {
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(labelText: label),
      keyboardType: keyboardType,
      validator: validator,
    );
  }
}
