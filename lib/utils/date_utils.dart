import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

int _numOfWeeks(int year) {
  DateTime dec28 = DateTime(year, 12, 28);
  int dayOfDec28 = int.parse(DateFormat("D").format(dec28));
  return ((dayOfDec28 - dec28.weekday + 10) / 7).floor();
}

int weekNumber(DateTime date) {
  int dayOfYear = int.parse(DateFormat("D").format(date));
  int woy = ((dayOfYear - date.weekday + 10) / 7).floor();
  if (woy < 1) {
    woy = _numOfWeeks(date.year - 1);
  } else if (woy > _numOfWeeks(date.year)) {
    woy = 1;
  }
  return woy;
}

DateFormat getDateFormatter(BuildContext context) {
  final tag = Localizations.localeOf(context).toLanguageTag();
  return DateFormat.yMMMd(tag);
}
