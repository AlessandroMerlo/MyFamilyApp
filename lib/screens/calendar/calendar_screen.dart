import 'package:calendar_view/calendar_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_family_app/constants/app_constants.dart';
import 'package:my_family_app/models/calendar_event_data.dart';
import 'package:my_family_app/models/users.dart';
import 'package:my_family_app/providers/calendar/calendar_stream_provider.dart';
import 'package:my_family_app/screens/calendar/add_event_screen.dart';
import 'package:my_family_app/services/user_service.dart';
import 'package:my_family_app/widgets/day_view.dart';
import 'package:my_family_app/widgets/main_app_bar.dart';
import 'package:my_family_app/widgets/main_drawer.dart';
import 'package:my_family_app/widgets/month_view.dart';
import 'package:my_family_app/widgets/week_view.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key, this.selectedTabIndex});

  final int? selectedTabIndex;

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen>
    with SingleTickerProviderStateMixin {
  late final TabController tabBarctrl;

  final List<MyUser> usersList = myUsersList;

  @override
  void initState() {
    tabBarctrl = TabController(length: 3, vsync: this);
    if (widget.selectedTabIndex != null) {
      tabBarctrl.index = widget.selectedTabIndex!;
    }

    super.initState();
  }

  String selectedButton = 'Mese';

  void changeSelectedButton(String newButton) {
    setState(() {
      selectedButton = newButton;
    });
  }

  @override
  Widget build(BuildContext context) {
    final calendarEventsDataList =
        ref.watch(calendarEventsStreamProvider).value;

    return Scaffold(
      extendBody: true,
      appBar: const MainAppBar(
        mainTitle: appTitle,
        backgroundColor: AppBarColors.events,
      ),
      drawer: const MainDrawer(),
      body: Scaffold(
        appBar: AppBar(
          foregroundColor: Colors.black,
          backgroundColor: Colors.white,
          title: const Text(
            'Calendario',
            style: TextStyle(
              color: Colors.teal,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          bottom: TabBar(
            labelColor: Colors.purple,
            indicatorSize: TabBarIndicatorSize.tab,
            indicatorColor: Colors.purple,
            unselectedLabelColor: Colors.teal[200],
            controller: tabBarctrl,
            tabs: [
              const Tab(
                child: Text(
                  'Tutte',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ),
              ...usersList
                  .map(
                    (myUser) => Tab(
                      child: Text(
                        myUser.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  )
                  .toList()
            ],
          ),
        ),
        body: calendarEventsDataList == null
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : TabBarView(
                controller: tabBarctrl,
                physics: const BouncingScrollPhysics(),
                children: [
                  CalendarTab(
                    calendarEventDataList: calendarEventsDataList,
                    selectedButton: selectedButton,
                    onChangeButton: changeSelectedButton,
                  ),
                  ...usersList.map(
                    (myUser) => CalendarTab(
                      calendarEventDataList: calendarEventsDataList
                          .where((calendarEventData) =>
                              calendarEventData
                                  .calendarEventData.event!.author ==
                              myUser.id)
                          .toList(),
                      onChangeButton: changeSelectedButton,
                      selectedButton: selectedButton,
                    ),
                  )
                ],
              ),
      ),
    );
  }

  @override
  void dispose() {
    tabBarctrl.dispose();
    super.dispose();
  }
}

class CalendarTab extends ConsumerStatefulWidget {
  const CalendarTab({
    super.key,
    required this.calendarEventDataList,
    required this.onChangeButton,
    required this.selectedButton,
  });

  final List<CalendarEventDataData> calendarEventDataList;
  final String selectedButton;
  final void Function(String newButton) onChangeButton;

  @override
  ConsumerState<CalendarTab> createState() => _CalendarTabState();
}

class _CalendarTabState extends ConsumerState<CalendarTab>
    with SingleTickerProviderStateMixin {
  DateTime selectedDate = DateTime.now();
  bool isDayClicked = false;
  String selectedElement = 'Month';

  Future<void> goToDayView(DateTime data) async {
    setState(() {
      isDayClicked = true;
      selectedElement = 'Day';
      selectedDate = data;
    });
  }

  Widget selectedWidget() {
    switch (selectedElement) {
      case 'Month':
        return MonthViewWidget(onDayClick: (date) => goToDayView(date));
      case 'Week':
        return WeekViewWidget(onDayClick: (date) => goToDayView(date));
      case "Day":
        return DayViewWidget(isDayClicked: true, selectedDate: selectedDate);
      default:
        return const SizedBox();
    }
  }

  @override
  Widget build(BuildContext context) {
    return CalendarControllerProvider(
      controller: EventController()
        ..addAll(widget.calendarEventDataList
            .map((element) => element.calendarEventData)
            .toList()),
      child: Scaffold(
        body: selectedWidget(),
        floatingActionButtonLocation: FloatingActionButtonLocation.miniEndFloat,
        floatingActionButton: FloatingActionButton(
          heroTag: 'add_event',
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const AddEventScreen(
                  updateMode: false,
                ),
              ),
            );
          },
          shape: const CircleBorder(),
          backgroundColor: Colors.teal,
          elevation: 12,
          child: const Icon(
            Icons.add,
            color: Colors.white,
            size: 50,
          ),
        ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.fromLTRB(8.0, 4, 8, 4),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => setState(() {
                    selectedDate = DateTime.now();
                    isDayClicked = false;
                    selectedElement = 'Month';
                  }),
                  style: ButtonStyle(
                    shape: const MaterialStatePropertyAll(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadiusDirectional.only(
                          topStart: Radius.circular(50),
                          bottomStart: Radius.circular(50),
                        ),
                      ),
                    ),
                    backgroundColor: MaterialStatePropertyAll(
                      selectedElement == 'Month'
                          ? Colors.teal
                          : const Color(0xFF80CBC4),
                    ),
                  ),
                  child: const Text(
                    'Mese',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => setState(() {
                    selectedElement = 'Week';
                  }),
                  style: ButtonStyle(
                    padding: const MaterialStatePropertyAll(
                        EdgeInsets.symmetric(vertical: 7)),
                    shape: const MaterialStatePropertyAll(
                      ContinuousRectangleBorder(),
                    ),
                    backgroundColor: MaterialStatePropertyAll(
                      selectedElement == 'Week'
                          ? Colors.teal
                          : const Color(0xFF80CBC4),
                    ),
                  ),
                  child: const Text(
                    'Settimana',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => setState(() {
                    selectedElement = 'Day';
                  }),
                  style: ButtonStyle(
                    shape: const MaterialStatePropertyAll(
                      ContinuousRectangleBorder(
                        borderRadius: BorderRadiusDirectional.only(
                          topEnd: Radius.circular(50),
                          bottomEnd: Radius.circular(50),
                        ),
                      ),
                    ),
                    backgroundColor: MaterialStatePropertyAll(
                      selectedElement == 'Day'
                          ? Colors.teal
                          : const Color(0xFF80CBC4),
                    ),
                  ),
                  child: const Text(
                    'Giorno',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
