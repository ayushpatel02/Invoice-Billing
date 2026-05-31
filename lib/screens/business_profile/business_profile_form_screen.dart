import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/business_profile.dart';
import '../../providers/business_profile_provider.dart';
import '../../providers/customer_provider.dart';
import '../../services/image_service.dart';
import '../../utils/validators.dart';
import '../../utils/date_formatter.dart';

class BusinessProfileFormScreen extends StatefulWidget {
  final bool isEdit;

  const BusinessProfileFormScreen({super.key, required this.isEdit});

  @override
  State<BusinessProfileFormScreen> createState() =>
      _BusinessProfileFormScreenState();
}

class _BusinessProfileFormScreenState
    extends State<BusinessProfileFormScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _saving = false;
  String? _logoPath;

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

  @override
  void initState() {
    super.initState();
    if (widget.isEdit) {
      final profile =
          context.read<BusinessProfileProvider>().profile;
      if (profile != null) _populateFrom(profile);
    }
  }

  void _populateFrom(BusinessProfile p) {
    _firstName.text = p.firstName;
    _middleName.text = p.middleName;
    _lastName.text = p.lastName;
    _address1.text = p.address1;
    _address2.text = p.address2;
    _address3.text = p.address3;
    _city.text = p.city;
    _state.text = p.state;
    _country.text = p.country;
    _district.text = p.district;
    _pinCode.text = p.pinCode;
    _phone.text = p.phone;
    _email.text = p.email;
    _logoPath = p.logoPath;
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

  Future<void> _pickLogo() async {
    final path = await ImageService.pickCompanyLogo();
    if (path != null && mounted) {
      setState(() => _logoPath = path);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final now = todayIso();
    final profile = BusinessProfile(
      id: 1,
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
      logoPath: _logoPath,
      createdAt: now,
      updatedAt: now,
    );

    final success =
        await context.read<BusinessProfileProvider>().saveProfile(profile);

    if (!mounted) return;
    setState(() => _saving = false);

    if (success) {
      if (widget.isEdit) {
        if (mounted) Navigator.pop(context);
      } else {
        await context.read<CustomerProvider>().loadCustomers();
        if (mounted) Navigator.pushReplacementNamed(context, '/home');
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to save profile')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEdit ? 'Edit Business Profile' : 'Setup Profile'),
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
            Center(
              child: GestureDetector(
                onTap: _pickLogo,
                child: Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey),
                    color: Colors.grey[200],
                  ),
                  child: _logoPath != null && File(_logoPath!).existsSync()
                      ? ClipOval(
                          child: Image.file(File(_logoPath!),
                              fit: BoxFit.cover))
                      : const Icon(Icons.add_a_photo,
                          size: 36, color: Colors.grey),
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Center(
              child: Text('Tap to set company logo',
                  style: TextStyle(color: Colors.grey, fontSize: 12)),
            ),
            const SizedBox(height: 16),
            Row(children: [
              Expanded(child: _tf('First Name *', _firstName, validator: requiredField)),
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
            _tf('Pin Code', _pinCode,
                keyboardType: TextInputType.number),
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
