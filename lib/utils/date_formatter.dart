import 'package:intl/intl.dart';

final _displayFmt = DateFormat('dd-MMM-yyyy');
final _isoFmt = DateFormat('yyyy-MM-dd');

String formatDisplayDate(String isoDate) {
  if (isoDate.isEmpty) return '';
  try {
    final date = DateTime.parse(isoDate);
    return _displayFmt.format(date);
  } catch (_) {
    return isoDate;
  }
}

String todayIso() => _isoFmt.format(DateTime.now());

String dateToIso(DateTime date) => _isoFmt.format(date);

DateTime? parseIsoDate(String isoDate) {
  try {
    return DateTime.parse(isoDate);
  } catch (_) {
    return null;
  }
}
