import 'package:flutter/material.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:intl/intl.dart';
import 'package:timezone/standalone.dart' as tz;
import 'package:timezone/standalone.dart';

final _dateFormatter = DateFormat('dd/MM/y', 'it_IT');
final _timeFormatter = DateFormat('HH:mm', 'it_IT');
final _dateTextInputFormatter = DateFormat('y-MM-dd', 'it-IT');

extension DateTimeX on DateTime {
  DateTime setTimeInDay(TimeOfDay time) {
    return DateTime(year, month, day, time.hour, time.minute);
  }

  Future<DateTime> withTimeZone() async {
    String timeZoneName = await FlutterTimezone.getLocalTimezone();

    Location timeZone = tz.getLocation(timeZoneName);

    return tz.TZDateTime.from(this, timeZone).toUtc();
  }

  String formatToItalian() {
    return _dateFormatter.format(this);
  }

  String formatToTextInput() {
    return _dateTextInputFormatter.format(this);
  }

  String formatTimeTotextInput() {
    return _timeFormatter.format(this);
  }

  String formatTime() {
    return _timeFormatter.format(this);
  }

  String firstLetterWeekDay() {
    return DateFormat.E('it-IT').format(this).substring(0, 1).toUpperCase();
  }

  bool isPastDate() {
    DateTime now = DateTime.now();

    return now.isBefore(this);
  }

  bool isNearDate() {
    DateTime now = DateTime.now();

    return now.add(const Duration(days: 30)).isBefore(this);
  }
}
