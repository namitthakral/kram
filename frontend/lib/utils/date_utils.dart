import 'package:intl/intl.dart';

class DateUtility {
  static String formatDate(DateTime date) => DateFormat('EEE, dd MMM yyyy').format(date);
}
