import 'package:calendar_view/calendar_view.dart';
import 'package:my_family_app/models/event_info.dart';

class CalendarEventDataData {
  final String key;
  final CalendarEventData<EventInfo> calendarEventData;

  CalendarEventDataData({
    required this.key,
    required this.calendarEventData,
  });
}
