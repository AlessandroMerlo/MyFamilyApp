import 'package:calendar_view/calendar_view.dart';
import 'package:flutter/material.dart';
import 'package:my_family_app/constants/app_constants.dart';
import 'package:my_family_app/extensions/date_time_x.dart';
import 'package:my_family_app/models/event_info.dart';
import 'package:my_family_app/screens/calendar/add_event_screen.dart';
import 'package:my_family_app/services/calendar_service.dart';
import 'package:my_family_app/widgets/main_app_bar.dart';

class DetailsCalendarEventScreen extends StatelessWidget {
  const DetailsCalendarEventScreen({
    super.key,
    required this.calendarEventData,
  });

  final CalendarEventData<EventInfo> calendarEventData;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      appBar: const MainAppBar(
        mainTitle: appTitle,
        backgroundColor: AppBarColors.events,
      ),
      body: Stack(
        children: [
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverFillRemaining(
                hasScrollBody: false,
                child: Column(
                  children: [
                    Container(
                      color: Colors.teal[300],
                      padding: const EdgeInsets.symmetric(
                          vertical: 24, horizontal: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Image.asset('assets/compleanno.png', height: 45),
                          Image.asset('assets/guitar.png', height: 45),
                          Image.asset('assets/office.png', height: 45),
                          Image.asset('assets/confetti.png', height: 45),
                          Image.asset('assets/floating-island-beach.png',
                              height: 45),
                          Image.asset('assets/albero-di-natale.png',
                              height: 45),
                          Image.asset('assets/national-park.png', height: 45),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 32,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Column(
                        children: [
                          Text(
                            calendarEventData.title,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontFamily: 'Marck Script',
                              fontSize: 50,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Text(
                      calendarEventData.date.formatToItalian(),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text(
                          'Da: ${calendarEventData.startTime!.formatTime()}',
                        ),
                        Row(
                          children: [
                            for (int i = 0; i < 5; i++)
                              Text(
                                String.fromCharCode(
                                    Icons.arrow_forward_ios_outlined.codePoint),
                                style: TextStyle(
                                  color: Colors.teal,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 28,
                                  fontFamily: Icons
                                      .arrow_forward_ios_outlined.fontFamily,
                                ),
                              ),
                          ],
                        ),
                        Text(
                          'A: ${calendarEventData.endTime!.formatTime()}',
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Text(
                      calendarEventData.description,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(
                      height: 32,
                    ),
                    Expanded(child: Container()),
                    Container(
                      color: Colors.teal[300],
                      padding: const EdgeInsets.symmetric(
                          vertical: 24, horizontal: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Image.asset('assets/compleanno.png', height: 45),
                          Image.asset('assets/guitar.png', height: 45),
                          Image.asset('assets/office.png', height: 45),
                          Image.asset('assets/confetti.png', height: 45),
                          Image.asset('assets/floating-island-beach.png',
                              height: 45),
                          Image.asset('assets/albero-di-natale.png',
                              height: 45),
                          Image.asset('assets/national-park.png', height: 45),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Positioned(
            left: 12,
            top: 12,
            child: Hero(
              tag: 'add_event',
              child: Material(
                color: Colors.blue[900],
                shape: const CircleBorder(),
                clipBehavior: Clip.antiAlias,
                elevation: 10,
                child: IconButton(
                  onPressed: () async {
                    var calendarDataData =
                        await getEventInfo(calendarEventData.event!.uid);
                    if (context.mounted) {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => AddEventScreen(
                                updateMode: true,
                                calendarEventDataDataToUpdate: calendarDataData,
                              )));
                    }
                  },
                  icon: const Icon(
                    Icons.edit,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
