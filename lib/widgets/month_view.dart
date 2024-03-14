import 'package:calendar_view/calendar_view.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_family_app/extensions/int_x.dart';
import 'package:my_family_app/extensions/string_x.dart';

class MonthViewWidget extends StatelessWidget {
  const MonthViewWidget({super.key, required this.onDayClick});

  final Function(DateTime date) onDayClick;

  @override
  Widget build(BuildContext context) {
    return MonthView(
      useAvailableVerticalSpace: true,
      onCellTap: (events, date) {
        onDayClick(date);
      },
      onEventTap: (event, date) {
        onDayClick(date);
      },
      cellBuilder:
          (date, List<CalendarEventData<Object?>> events, isToday, isInMonth) {
        return Container(
          padding: const EdgeInsets.all(2),
          color: isToday
              ? Colors.teal[50]
              : isInMonth
                  ? Colors.white
                  : Colors.grey[200],
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: isToday
                      ? ShapeDecoration(
                          shape: const CircleBorder(),
                          color: Colors.teal[800],
                        )
                      : const BoxDecoration(),
                  child: Text(
                    '${date.day}',
                    style: TextStyle(
                        color: isToday ? Colors.white : Colors.grey,
                        fontSize: 14,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              if (events.length > 1)
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: ShapeDecoration(
                      color: Colors.teal[400],
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(15),
                        ),
                      ),
                    ),
                    child: Text(
                      '+ ${events.length}',
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.fade,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                )
              else
                ...events
                    .map((event) => Expanded(
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              vertical: 4,
                              horizontal: 8,
                            ),
                            decoration: ShapeDecoration(
                              color: Colors.teal[400],
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(15),
                                ),
                              ),
                            ),
                            child: Text(
                              event.title,
                              maxLines: 2,
                              overflow: TextOverflow.fade,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700),
                            ),
                          ),
                        ))
                    .toList(),
            ],
          ),
        );
      },
      weekDayBuilder: (day) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 6.0),
          decoration: BoxDecoration(
              border: Border.all(color: Colors.teal), color: Colors.teal[50]),
          alignment: Alignment.center,
          child: Text(
            day.firstLetterWeekDayByIndex(),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        );
      },
      headerStyle: const HeaderStyle(
        decoration: BoxDecoration(color: Color(0xFFB2DFDB)),
        headerTextStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
      ),
      headerStringBuilder: (date, {secondaryDate}) =>
          '${DateFormat('MMMM', 'it-IT').format(date).toTitleCase()} ${DateFormat.y('it-IT').format(date)}',
    );
  }
}
