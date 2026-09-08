import 'package:intl/intl.dart';

String getOrdinalDate(DateTime date) {
  final day = date.day;
  final suffix = _ordinalSuffix(day);
  final monthYear = DateFormat('MMMM, yyyy').format(date);
  return '$day$suffix $monthYear';
}

String _ordinalSuffix(int day) {
  if (day >= 11 && day <= 13) return 'th'; // 11th, 12th, 13th are exceptions
  switch (day % 10) {
    case 1:
      return 'st';
    case 2:
      return 'nd';
    case 3:
      return 'rd';
    default:
      return 'th';
  }
}