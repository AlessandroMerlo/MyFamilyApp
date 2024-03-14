import 'dart:async';

import 'package:calendar_view/calendar_view.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_family_app/data/database.dart';
import 'package:my_family_app/extensions/calendar_event_data_x.dart';
import 'package:my_family_app/models/calendar_event_data.dart';
import 'package:my_family_app/models/event_info.dart';

const String path = 'calendar_events';

final DatabaseReference _databaseRef = FireBaseRealTimeDatabase.database.ref();

final calendarEventsStreamProvider =
    StreamProvider<List<CalendarEventDataData>>((ref) {
  final streamController = StreamController<List<CalendarEventDataData>>();

  final calentarEventsList = <CalendarEventDataData>[];

  Query query = _databaseRef.child(path);

  query.onChildAdded.listen((event) {
    CalendarEventData<EventInfo> calendarEvent = calendarEventDataFromJson(
        event.snapshot.value as Map, event.snapshot.key!);
    CalendarEventDataData calendarEventData = CalendarEventDataData(
        key: event.snapshot.key!, calendarEventData: calendarEvent);

    calentarEventsList.add(calendarEventData);
    streamController.add(calentarEventsList);
  });

  query.onChildRemoved.listen((event) {
    calentarEventsList
        .removeWhere((element) => element.key == event.snapshot.key);
    streamController.add(calentarEventsList);
  });

  query.onChildChanged.listen((event) {
    CalendarEventData<EventInfo> updatedCalendarEvent =
        calendarEventDataFromJson(
            event.snapshot.value as Map, event.snapshot.key!);
    CalendarEventDataData updatedShoppingChartData = CalendarEventDataData(
        key: event.snapshot.key!, calendarEventData: updatedCalendarEvent);

    int indexOf = calentarEventsList
        .indexWhere((element) => element.key == event.snapshot.key);

    if (indexOf != -1) {
      calentarEventsList[indexOf] = updatedShoppingChartData;
      streamController.add(calentarEventsList);
    }
  });

  return streamController.stream;
});
