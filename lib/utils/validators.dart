String? requiredField(String? value) {
  if (value == null || value.trim().isEmpty) return 'This field is required';
  return null;
}

String? validEmail(String? value) {
  if (value == null || value.trim().isEmpty) return null;
  final re = RegExp(r'^[\w.+\-]+@[a-zA-Z0-9\-]+\.[a-zA-Z]{2,}$');
  if (!re.hasMatch(value.trim())) return 'Enter a valid email address';
  return null;
}

String? validPhone(String? value) {
  if (value == null || value.trim().isEmpty) return null;
  if (value.trim().length < 7) return 'Enter a valid phone number';
  return null;
}

String? positiveNumber(String? value) {
  if (value == null || value.trim().isEmpty) return 'This field is required';
  final n = double.tryParse(value.trim());
  if (n == null) return 'Enter a valid number';
  if (n <= 0) return 'Must be greater than 0';
  return null;
}

String? nonNegativeNumber(String? value) {
  if (value == null || value.trim().isEmpty) return 'This field is required';
  final n = double.tryParse(value.trim());
  if (n == null) return 'Enter a valid number';
  if (n < 0) return 'Must be 0 or greater';
  return null;
}
