import 'package:calendar_view/calendar_view.dart';
import 'package:flutter/material.dart';
import 'package:my_family_app/extensions/date_time_x.dart';
import 'package:my_family_app/models/event_info.dart';
import 'package:my_family_app/utils/date_utils.dart';

class WeekViewWidget extends StatelessWidget {
  const WeekViewWidget({super.key, required this.onDayClick});

  final Function(DateTime date) onDayClick;

  @override
  Widget build(BuildContext context) {
    return WeekView(
      onDateTap: (date) => onDayClick(date),
      eventTileBuilder: (date, List<CalendarEventData> events, boundary,
          startDuration, endDuration) {
        return LayoutBuilder(
          builder: (context, constraints) {
            return Container(
              padding: const EdgeInsets.all(6),
              decoration: ShapeDecoration(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                color: !(events[0].event as EventInfo).isFullDayEvent
                    ? Colors.teal
                    : Colors.deepPurple,
              ),
              child: Text(
                constraints.maxWidth > 25 ? events[0].title : '',
                overflow: TextOverflow.fade,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            );
          },
        );
      },
      headerStyle: const HeaderStyle(
        decoration: BoxDecoration(color: Color(0xFFB2DFDB)),
        headerTextStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
      ),
      weekDayBuilder: (dateTime) {
        return InkWell(
          onTap: () => onDayClick(dateTime),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.teal),
              color: Colors.teal[50],
            ),
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  dateTime.firstLetterWeekDay(),
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  '${dateTime.day}',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        );
      },
      weekNumberBuilder: (dateTime) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.teal,
          ),
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'SETT',
                style: TextStyle(color: Colors.white),
              ),
              Text(
                '${weekNumber(dateTime)}',
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
            ],
          ),
        );
      },
      headerStringBuilder: (date, {secondaryDate}) {
        return '${date.formatToItalian()} >> ${secondaryDate!.formatToItalian()}';
      },
    );
  }
}
