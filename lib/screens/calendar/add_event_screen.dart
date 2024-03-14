import 'package:calendar_view/calendar_view.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:my_family_app/auth/fire_auth.dart';
import 'package:my_family_app/constants/app_constants.dart';
import 'package:my_family_app/extensions/date_time_x.dart';
import 'package:my_family_app/models/calendar_event_data.dart';
import 'package:my_family_app/models/event_info.dart';
import 'package:my_family_app/screens/calendar/calendar_screen.dart';
import 'package:my_family_app/services/calendar_service.dart';
import 'package:my_family_app/utils/constants.dart';
import 'package:my_family_app/widgets/main_app_bar.dart';

class AddEventScreen extends StatefulWidget {
  const AddEventScreen({
    super.key,
    required this.updateMode,
    this.calendarEventDataDataToUpdate,
  });

  final bool updateMode;
  final CalendarEventDataData? calendarEventDataDataToUpdate;

  @override
  State<AddEventScreen> createState() => _AddEventScreenState();
}

class _AddEventScreenState extends State<AddEventScreen> {
  final formKey = GlobalKey<FormState>();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController startingTimeController = TextEditingController();
  final TextEditingController endingTimeController = TextEditingController();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  DateTime? selectedDate;
  TimeOfDay? selectedStartingTime;
  TimeOfDay? selectedEndingTime;

  final FocusNode dateInputFocus = FocusNode();
  final FocusNode startingTimeInputFocus = FocusNode();
  final FocusNode endingTimeInputFocus = FocusNode();
  final FocusNode titleInputFocus = FocusNode();
  final FocusNode descriptionInputFocus = FocusNode();

  late String? _authorUid;
  late bool isFullDayEvent;

  late CalendarEventDataData calendarEventDataData;

  @override
  void initState() {
    super.initState();

    if (widget.calendarEventDataDataToUpdate != null) {
      calendarEventDataData = widget.calendarEventDataDataToUpdate!;

      CalendarEventData<EventInfo> calendarEvent =
          calendarEventDataData.calendarEventData;
      EventInfo eventInfo = calendarEvent.event!;

      _authorUid = eventInfo.author;
      dateController.text = calendarEvent.date.formatToTextInput();
      selectedDate = calendarEvent.date;
      startingTimeController.text =
          calendarEvent.startTime!.formatTimeTotextInput();
      selectedStartingTime = TimeOfDay.fromDateTime(calendarEvent.startTime!);
      endingTimeController.text =
          calendarEvent.endTime!.formatTimeTotextInput();
      selectedEndingTime = TimeOfDay.fromDateTime(calendarEvent.endTime!);
      titleController.text = calendarEvent.title;
      descriptionController.text = calendarEvent.description;

      isFullDayEvent = eventInfo.isFullDayEvent;
    } else {
      User? currentUser = FireAuth.getUser();

      _authorUid = currentUser!.uid;

      isFullDayEvent = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      appBar: const MainAppBar(
        mainTitle: appTitle,
        backgroundColor: AppBarColors.events,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${widget.updateMode ? 'Modifica' : 'Aggiungi'} un evento',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              const Divider(
                color: Colors.teal,
                thickness: 1,
                height: 32,
              ),
              Form(
                key: formKey,
                child: Column(
                  children: [
                    const Text(
                      'Data di inizio:',
                      style: TextStyle(fontSize: 24),
                    ),
                    const SizedBox(
                      height: 12,
                    ),
                    TextFormField(
                      controller: dateController,
                      focusNode: dateInputFocus,
                      decoration: const InputDecoration(
                        icon: Icon(
                          Icons.calendar_today,
                          color: Colors.teal,
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.teal),
                        ),
                        labelText: "Seleziona una data",
                        floatingLabelStyle: TextStyle(
                          color: Colors.teal,
                        ),
                      ),
                      readOnly: true,
                      onTap: () async {
                        DateTime? pickedDate = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(1950),
                            lastDate: DateTime(2101),
                            builder: (context, child) {
                              return Theme(
                                data: Theme.of(context).copyWith(
                                  colorScheme: const ColorScheme.light(
                                      primary: Colors.teal),
                                ),
                                child: child!,
                              );
                            });

                        if (pickedDate != null) {
                          dateController.text = pickedDate.formatToTextInput();
                          selectedDate = pickedDate;
                          setState(() {});
                        }
                      },
                    ),
                    const SizedBox(
                      height: 12,
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            children: [
                              TextFormField(
                                enabled: !isFullDayEvent &&
                                    dateController.value.text != '',
                                controller: startingTimeController,
                                focusNode: startingTimeInputFocus,
                                decoration: InputDecoration(
                                  icon: Icon(
                                    Icons.timer_sharp,
                                    color: !isFullDayEvent
                                        ? Colors.teal
                                        : Colors.teal[200],
                                  ),
                                  focusedBorder: const UnderlineInputBorder(
                                    borderSide: BorderSide(color: Colors.teal),
                                  ),
                                  labelText: "Inizio",
                                  floatingLabelStyle: const TextStyle(
                                    color: Colors.teal,
                                  ),
                                ),
                                readOnly: true,
                                onTap: () async {
                                  TimeOfDay? pickedTime = await showTimePicker(
                                      context: context,
                                      initialTime: const TimeOfDay(
                                        hour: 0,
                                        minute: 0,
                                      ),
                                      builder: (context, child) {
                                        return Theme(
                                          data: Theme.of(context).copyWith(
                                            colorScheme:
                                                const ColorScheme.light(
                                                    primary: Colors.teal),
                                          ),
                                          child: child!,
                                        );
                                      });

                                  if (pickedTime != null) {
                                    List<String> dateInfo =
                                        dateController.value.text.split('-');
                                    startingTimeController.text = DateTime(
                                            int.parse(dateInfo[0]),
                                            int.parse(dateInfo[1]),
                                            int.parse(dateInfo[2]))
                                        .setTimeInDay(pickedTime)
                                        .formatTimeTotextInput();
                                    selectedStartingTime = pickedTime;
                                    setState(() {});
                                  }
                                },
                              ),
                              TextFormField(
                                enabled: !isFullDayEvent &&
                                    dateController.value.text != '' &&
                                    startingTimeController.value.text != '',
                                controller: endingTimeController,
                                focusNode: endingTimeInputFocus,
                                decoration: InputDecoration(
                                  icon: Icon(
                                    Icons.timer_off_outlined,
                                    color: !isFullDayEvent
                                        ? Colors.teal
                                        : Colors.teal[200],
                                  ),
                                  focusedBorder: const UnderlineInputBorder(
                                    borderSide: BorderSide(color: Colors.teal),
                                  ),
                                  labelText: "Fine",
                                  floatingLabelStyle: const TextStyle(
                                    color: Colors.teal,
                                  ),
                                ),
                                readOnly: true,
                                onTap: () async {
                                  TimeOfDay? pickedTime = await showTimePicker(
                                      context: context,
                                      initialTime: TimeOfDay(
                                        hour: startingTimeController
                                                    .value.text !=
                                                ''
                                            ? int.parse(startingTimeController
                                                .value.text
                                                .split(':')[0])
                                            : 0,
                                        minute: startingTimeController
                                                    .value.text !=
                                                ''
                                            ? int.parse(startingTimeController
                                                .value.text
                                                .split(':')[1])
                                            : 0,
                                      ),
                                      builder: (context, child) {
                                        return Theme(
                                          data: Theme.of(context).copyWith(
                                            colorScheme:
                                                const ColorScheme.light(
                                                    primary: Colors.teal),
                                          ),
                                          child: child!,
                                        );
                                      });
                                  startingTimeController.value.text
                                      .split(':')[0];

                                  if (pickedTime != null) {
                                    if (selectedDate!
                                            .copyWith()
                                            .setTimeInDay(pickedTime)
                                            .compareTo(selectedDate!
                                                .copyWith()
                                                .setTimeInDay(
                                                    selectedStartingTime!)) >
                                        0) {
                                      List<String> dateInfo =
                                          dateController.value.text.split('-');
                                      endingTimeController.text = DateTime(
                                              int.parse(dateInfo[0]),
                                              int.parse(dateInfo[1]),
                                              int.parse(dateInfo[2]))
                                          .setTimeInDay(pickedTime)
                                          .formatTimeTotextInput();
                                      selectedEndingTime = pickedTime;
                                    }
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          width: 12,
                        ),
                        Column(
                          children: [
                            const Text('Tutto il giorno'),
                            Switch(
                                thumbIcon:
                                    MaterialStateProperty.resolveWith<Icon?>(
                                        (Set<MaterialState> states) {
                                  return isFullDayEvent
                                      ? const Icon(
                                          Icons.check,
                                          color: Colors.white,
                                          weight: 1000,
                                          size: 25,
                                        )
                                      : const Icon(
                                          Icons.close,
                                          color: Colors.teal,
                                          weight: 1000,
                                          size: 25,
                                        );
                                }),
                                activeColor: Colors.teal,
                                splashRadius: 50.0,
                                value: isFullDayEvent,
                                onChanged: (value) {
                                  setState(() {
                                    isFullDayEvent = value;
                                  });
                                }),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 12,
                    ),
                    TextFormField(
                      controller: titleController,
                      focusNode: titleInputFocus,
                      decoration: const InputDecoration(
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.teal),
                        ),
                        floatingLabelStyle: TextStyle(
                          color: Colors.teal,
                        ),
                        hintText: 'Titolo',
                        labelText: 'Titolo',
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    TextFormField(
                      controller: descriptionController,
                      focusNode: descriptionInputFocus,
                      keyboardType: TextInputType.multiline,
                      maxLines: null,
                      decoration: const InputDecoration(
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.teal),
                          ),
                          floatingLabelStyle: TextStyle(
                            color: Colors.teal,
                          ),
                          hintText: 'Descrizione',
                          labelText: 'Descrizione'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'add_event',
        onPressed: () async {
          if (selectedDate == null) {
            showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text('Warning'),
                content: RichText(
                  text: const TextSpan(
                    style: TextStyle(color: Colors.black, height: 1.5),
                    children: [
                      TextSpan(
                        text: 'Non hai selezionato una data!!! ',
                      ),
                      TextSpan(
                        text: 'Indica una data',
                      ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      FocusScope.of(context).requestFocus(dateInputFocus);
                    },
                    child: const Text(
                      'Ok, capito',
                      style: TextStyle(
                        color: Colors.teal,
                      ),
                    ),
                  ),
                ],
              ),
            );
          } else if (selectedStartingTime == null && !isFullDayEvent) {
            showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text('Warning'),
                content: RichText(
                  text: const TextSpan(
                    style: TextStyle(color: Colors.black, height: 1.5),
                    children: [
                      TextSpan(
                        text: 'Non hai selezionato un orario di inizio!!! ',
                      ),
                      TextSpan(
                        text: 'Indica una orario',
                      ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      FocusScope.of(context)
                          .requestFocus(startingTimeInputFocus);
                    },
                    child: const Text(
                      'Ok, capito',
                      style: TextStyle(
                        color: Colors.teal,
                      ),
                    ),
                  ),
                ],
              ),
            );
          } else if (selectedEndingTime == null && !isFullDayEvent) {
            showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text('Warning'),
                content: RichText(
                  text: const TextSpan(
                    style: TextStyle(color: Colors.black, height: 1.5),
                    children: [
                      TextSpan(
                        text: 'Non hai selezionato un orario di fine!!! ',
                      ),
                      TextSpan(
                        text: 'Indica una orario',
                      ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      FocusScope.of(context).requestFocus(endingTimeInputFocus);
                    },
                    child: const Text(
                      'Ok, capito',
                      style: TextStyle(
                        color: Colors.teal,
                      ),
                    ),
                  ),
                ],
              ),
            );
          } else {
            CalendarEventData<EventInfo> newCalendarEvent;

            if (!isFullDayEvent) {
              newCalendarEvent = CalendarEventData(
                title: titleController.value.text,
                description: descriptionController.value.text,
                date: await DateTime(
                        selectedDate!.year,
                        selectedDate!.month,
                        selectedDate!.day,
                        selectedStartingTime!.hour,
                        selectedStartingTime!.minute)
                    .withTimeZone(),
                endDate: await DateTime(
                        selectedDate!.year,
                        selectedDate!.month,
                        selectedDate!.day,
                        selectedEndingTime!.hour,
                        selectedEndingTime!.minute)
                    .withTimeZone(),
                startTime: await DateTime(
                        selectedDate!.year,
                        selectedDate!.month,
                        selectedDate!.day,
                        selectedStartingTime!.hour,
                        selectedStartingTime!.minute)
                    .withTimeZone(),
                endTime: await DateTime(
                        selectedDate!.year,
                        selectedDate!.month,
                        selectedDate!.day,
                        selectedEndingTime!.hour,
                        selectedEndingTime!.minute)
                    .withTimeZone(),
                event: EventInfo(
                    title: titleController.value.text,
                    author: _authorUid!,
                    isFullDayEvent: false),
              );
            } else {
              newCalendarEvent = CalendarEventData(
                title: titleController.value.text,
                description: descriptionController.value.text,
                date: await DateTime(selectedDate!.year, selectedDate!.month,
                        selectedDate!.day)
                    .withTimeZone(),
                endDate: await DateTime(selectedDate!.year, selectedDate!.month,
                        selectedDate!.day, 23, 59, 59)
                    .withTimeZone(),
                startTime: await DateTime(selectedDate!.year,
                        selectedDate!.month, selectedDate!.day)
                    .withTimeZone(),
                endTime: await DateTime(selectedDate!.year, selectedDate!.month,
                        selectedDate!.day, 23, 59, 59)
                    .withTimeZone(),
                event: EventInfo(
                    title: titleController.value.text,
                    author: _authorUid!,
                    isFullDayEvent: true),
              );
            }

            DatabaseCallStatus callStatus;

            if (widget.updateMode) {
              CalendarEventDataData updatedCalendarEventData =
                  CalendarEventDataData(
                      key: calendarEventDataData.key,
                      calendarEventData: newCalendarEvent);
              callStatus = await updateCalendarEventData(
                  newCalendarEventDataData: updatedCalendarEventData);
            } else {
              callStatus = await createCalendarEventData(
                  newCalendarEventData: newCalendarEvent);
            }

            if (callStatus == DatabaseCallStatus.error) {
              if (mounted) {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Warning'),
                    content:
                        const Text('Qualcosa è andato storto con il database.'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text('Ok, capito'),
                      ),
                    ],
                  ),
                );
              }
            } else {
              if (mounted) {
                await Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CalendarScreen(),
                  ),
                  (Route<dynamic> route) => false,
                );
              }
            }
          }
        },
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(36),
        ),
        backgroundColor: Colors.teal,
        elevation: 12,
        label: const Text(
          'Salva',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    dateController.dispose();
    startingTimeController.dispose();
    endingTimeController.dispose();
    titleController.dispose();
    descriptionController.dispose();
    dateInputFocus.dispose();
    startingTimeInputFocus.dispose();
    endingTimeInputFocus.dispose();
    titleInputFocus.dispose();
    descriptionInputFocus.dispose();

    super.dispose();
  }
}
