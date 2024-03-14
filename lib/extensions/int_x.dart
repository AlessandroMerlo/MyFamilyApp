import 'package:intl/intl.dart';

extension IntX on int {
  String firstLetterWeekDayByIndex() {
    var weekDays =
        List.from(DateFormat.EEEE('it-IT').dateSymbols.STANDALONEWEEKDAYS);
    var firstDay = weekDays.removeAt(0);
    weekDays.add(firstDay);
    return weekDays[this].substring(0, 1).toUpperCase();
  }
}
