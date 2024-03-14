import 'package:calendar_view/calendar_view.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_family_app/extensions/string_x.dart';
import 'package:my_family_app/models/event_info.dart';
import 'package:my_family_app/screens/calendar/details_calendar_event_screen.dart';
import 'package:my_family_app/services/user_service.dart';

class DayViewWidget extends StatefulWidget {
  const DayViewWidget(
      {super.key, required this.isDayClicked, required this.selectedDate});

  final bool isDayClicked;
  final DateTime selectedDate;

  @override
  State<DayViewWidget> createState() => _DayViewWidgetState();
}

class _DayViewWidgetState extends State<DayViewWidget> {
  final GlobalKey<DayViewState> dayGlobalKey = GlobalKey<DayViewState>();

  bool isLoading = true;
  late DateTime selectedDate;

  @override
  void initState() {
    super.initState();

    if (widget.isDayClicked) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (dayGlobalKey.currentState != null) {
          dayGlobalKey.currentState!.animateToDate(widget.selectedDate);
          isLoading = false;
          setState(() {});
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        Expanded(
          child: DayView(
            key: dayGlobalKey,
            showHalfHours: true,
            heightPerMinute: 1.5,
            onEventTap: (events, date) {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => DetailsCalendarEventScreen(
                    calendarEventData:
                        events[0] as CalendarEventData<EventInfo>,
                  ),
                ),
              );
            },
            eventTileBuilder:
                (date, events, boundary, startDuration, endDuration) {
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
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(4),
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              decoration: const ShapeDecoration(
                                shape: CircleBorder(),
                                color: Colors.white,
                              ),
                              child: Image.asset(
                                'assets/icons/${(myUsersList.firstWhere((element) => element.id == (events[0].event as EventInfo).author)).iconName}.png',
                                height: 24,
                              ),
                            ),
                            Text(
                              constraints.maxWidth > 25 ? events[0].title : '',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 6,
                        ),
                        Flexible(
                          child: Center(
                            child: Text(
                              constraints.maxWidth > 25
                                  ? events[0].description
                                  : '',
                              style: const TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
            timeStringBuilder: (date, {secondaryDate}) =>
                DateFormat.Hm().format(date),
            headerStyle: const HeaderStyle(
              decoration: BoxDecoration(color: Color(0xFFB2DFDB)),
              headerTextStyle:
                  TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            dateStringBuilder: (date, {secondaryDate}) =>
                '${DateFormat.d().format(date)} ${DateFormat('MMMM', 'it-IT').format(date).toTitleCase()} ${DateFormat.y('it-IT').format(date)}',
          ),
        ),
      ],
    );
  }
}
