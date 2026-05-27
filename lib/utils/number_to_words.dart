const _ones = [
  '', 'One', 'Two', 'Three', 'Four', 'Five', 'Six', 'Seven', 'Eight', 'Nine',
  'Ten', 'Eleven', 'Twelve', 'Thirteen', 'Fourteen', 'Fifteen', 'Sixteen',
  'Seventeen', 'Eighteen', 'Nineteen'
];
const _tens = [
  '', '', 'Twenty', 'Thirty', 'Forty', 'Fifty',
  'Sixty', 'Seventy', 'Eighty', 'Ninety'
];

String _convert(int n) {
  if (n == 0) return '';
  if (n < 20) return _ones[n];
  if (n < 100) {
    return '${_tens[n ~/ 10]}${n % 10 != 0 ? ' ${_ones[n % 10]}' : ''}';
  }
  if (n < 1000) {
    return '${_ones[n ~/ 100]} Hundred${n % 100 != 0 ? ' ${_convert(n % 100)}' : ''}';
  }
  return '';
}

String numberToWords(double amount) {
  if (amount <= 0) return 'Zero Rupees Only';

  final rupees = amount.floor();
  final paise = ((amount - rupees) * 100).round();

  String result = _toIndianWords(rupees);

  if (paise > 0) {
    result += ' Rupees and ${_toIndianWords(paise)} Paise Only';
  } else {
    result += ' Rupees Only';
  }
  return result;
}

String _toIndianWords(int n) {
  if (n == 0) return 'Zero';

  String result = '';

  if (n >= 10000000) {
    result += '${_toIndianWords(n ~/ 10000000)} Crore ';
    n = n % 10000000;
  }
  if (n >= 100000) {
    result += '${_toIndianWords(n ~/ 100000)} Lakh ';
    n = n % 100000;
  }
  if (n >= 1000) {
    result += '${_convert(n ~/ 1000)} Thousand ';
    n = n % 1000;
  }
  result += _convert(n);
  return result.trim();
}
