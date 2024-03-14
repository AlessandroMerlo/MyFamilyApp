import 'package:calendar_view/calendar_view.dart';
import 'package:my_family_app/models/event_info.dart';

CalendarEventData<EventInfo> calendarEventDataFromJson(
    Map<dynamic, dynamic> json, String key) {
  var eventJson = (json['event'] as Map<dynamic, dynamic>)
    ..putIfAbsent('key', () => key);
  EventInfo eventInfo = EventInfo.fromJson(eventJson);
  return CalendarEventData<EventInfo>(
    date: DateTime.parse(json['date'] as String).toLocal(),
    title: json['title'],
    event: eventInfo,
    description: json['description'],
    startTime: DateTime.parse(json['startTime'] as String).toLocal(),
    endTime: DateTime.parse(json['endTime'] as String).toLocal(),
  );
}
