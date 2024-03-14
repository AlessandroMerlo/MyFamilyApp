import 'package:calendar_view/calendar_view.dart';
import 'package:my_family_app/data/database.dart';
import 'package:my_family_app/models/calendar_event_data.dart';
import 'package:my_family_app/models/event_info.dart';
import 'package:my_family_app/utils/constants.dart';
import 'package:my_family_app/utils/converter.dart';

const String path = 'calendar_events';

Future<CalendarEventDataData?> getEventInfo(String uid) async {
  var snapshot =
      await FireBaseRealTimeDatabase.database.ref().child(path).once();

  Map calendarEventsData =
      Map<String, dynamic>.from(snapshot.snapshot.value as Map);

  CalendarEventDataData? calendarEventDataData;

  for (MapEntry<dynamic, dynamic> calendarEventData
      in calendarEventsData.entries) {
    if (calendarEventData.value['event']['uid'] == uid) {
      var calendarMap = calendarEventData.value as Map;
      EventInfo eventInfo = EventInfo.fromJson(calendarMap['event']);
      CalendarEventData<EventInfo> calendarEvent = CalendarEventData<EventInfo>(
          date: DateTime.parse(calendarMap['date'] as String).toLocal(),
          description: calendarMap['description'],
          endDate: DateTime.parse(calendarMap['endDate'] as String).toLocal(),
          endTime: DateTime.parse(calendarMap['endTime'] as String).toLocal(),
          startTime:
              DateTime.parse(calendarMap['startTime'] as String).toLocal(),
          title: calendarMap['title'],
          event: eventInfo);
      calendarEventDataData = CalendarEventDataData(
          key: calendarEventData.key, calendarEventData: calendarEvent);
    }
  }

  return calendarEventDataData;
}

Future<DatabaseCallStatus> createCalendarEventData(
    {required CalendarEventData newCalendarEventData}) async {
  return await FireBaseRealTimeDatabase.create(
    path: path,
    newObject: convertDynamicMap(newCalendarEventData.toJson()),
  );
}

Future<DatabaseCallStatus> updateCalendarEventData(
    {required CalendarEventDataData newCalendarEventDataData}) async {
  return await FireBaseRealTimeDatabase.update(
    path: path,
    key: newCalendarEventDataData.key,
    newObject:
        convertDynamicMap(newCalendarEventDataData.calendarEventData.toJson()),
  );
}

Future<DatabaseCallStatus> deleteCalendarEventData(
    {required String key}) async {
  return await FireBaseRealTimeDatabase.delete(
    path: path,
    key: key,
  );
}
