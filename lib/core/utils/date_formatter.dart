// ============================================================
// lib/core/utils/date_formatter.dart
// ============================================================
import 'package:intl/intl.dart';
 
class DateFormatter {
  DateFormatter._();
 
  static String toDisplay(DateTime date) {
    return DateFormat('dd/MM/yyyy HH:mm', 'es_EC').format(date);
  }
 
  static String toDate(DateTime date) {
    return DateFormat('dd/MM/yyyy', 'es_EC').format(date);
  }
 
  static String toTime(DateTime date) {
    return DateFormat('HH:mm', 'es_EC').format(date);
  }
}