import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_family_app/auth/fire_auth.dart';
import 'package:my_family_app/constants/app_constants.dart';
import 'package:my_family_app/extensions/date_time_x.dart';
import 'package:my_family_app/models/users.dart';
import 'package:my_family_app/providers/note/note_stream_provider.dart';
import 'package:my_family_app/screens/note/add_note_screen.dart';
import 'package:my_family_app/services/note_service.dart';
import 'package:my_family_app/services/user_service.dart';
import 'package:my_family_app/utils/constants.dart';
import 'package:my_family_app/widgets/main_app_bar.dart';
import 'package:my_family_app/widgets/main_drawer.dart';
import 'package:my_family_app/widgets/notes_modal.dart';

import '../../models/note.dart';

class NotesScreen extends ConsumerStatefulWidget {
  const NotesScreen({super.key, this.selectedTabIndex});

  final int? selectedTabIndex;

  @override
  ConsumerState<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends ConsumerState<NotesScreen>
    with SingleTickerProviderStateMixin {
  late final TabController nestedTabBarctrl;

  final List<MyUser> usersList = myUsersList;

  @override
  void initState() {
    nestedTabBarctrl = TabController(length: 3, vsync: this);

    if (widget.selectedTabIndex != null) {
      nestedTabBarctrl.index = widget.selectedTabIndex!;
    }

    // getAuthorName();
    super.initState();
  }

  // getAuthorName() async {
  //   var users = await FireBaseRealTimeDatabase.getUsers();
  //   for (var user in users.values) {
  //     userInfo.add(MyUser.fromJson(user));
  //   }

  //   setState(() {});
  //   return;
  // }

  @override
  Widget build(BuildContext context) {
    final notesList = ref.watch(noteStreamProvider).value;
    return Scaffold(
      extendBody: true,
      appBar: const MainAppBar(
        mainTitle: appTitle,
        backgroundColor: AppBarColors.note,
      ),
      drawer: const MainDrawer(),
      body: Scaffold(
        appBar: AppBar(
          foregroundColor: Colors.black,
          backgroundColor: Colors.white,
          title: const Text(
            'Note',
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
            onTap: (value) {
              setState(() {
                nestedTabBarctrl.animateTo(value);
              });
            },
            controller: nestedTabBarctrl,
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
              // Tab(
              //   child: Text(
              //     'Muu',
              //     style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              //   ),
              // ),
              // Tab(
              //   child: Text(
              //     'Mek',
              //     style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              //   ),
              // ),
            ],
          ),
        ),
        body: notesList == null || notesList.isEmpty
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : TabBarView(
                controller: nestedTabBarctrl,
                physics: const BouncingScrollPhysics(),
                children: [
                  NotesListTab(
                    notesList: notesList,
                    selectedTab: nestedTabBarctrl.index,
                  ),
                  ...usersList
                      .map(
                        (myUser) => NotesListTab(
                          notesList: notesList
                              .where((noteData) =>
                                  noteData.note.author == myUser.id)
                              .toList(),
                          selectedTab: nestedTabBarctrl.index,
                        ),
                      )
                      .toList()
                  // NotesListTab(
                  //   selectedAuthor: 'Muu',
                  //   notesList: notesList.where((element) {
                  //     return element.note.author == FireAuth.getUser()!.uid;
                  //   }).toList(),
                  //   selectedTab: nestedTabBarctrl.index,
                  // ),
                  // NotesListTab(
                  //   selectedAuthor: 'Mek',
                  //   notesList: notesList,
                  //   selectedTab: nestedTabBarctrl.index,
                  // ),
                ],
              ),
        floatingActionButtonLocation: FloatingActionButtonLocation.miniEndFloat,
        floatingActionButton: FloatingActionButton(
          heroTag: 'add_note',
          onPressed: () {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => const AddNoteScreen(updateMode: false),
            ));
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
      ),
    );
  }

  @override
  void dispose() {
    nestedTabBarctrl.dispose();

    super.dispose();
  }
}

class NotesListTab extends StatefulWidget {
  const NotesListTab({
    super.key,
    this.selectedAuthor = 'Tutte',
    required this.notesList,
    required this.selectedTab,
  });

  final String selectedAuthor;
  final List<NoteData> notesList;
  final int selectedTab;

  @override
  State<NotesListTab> createState() => _NotesListTabState();
}

class _NotesListTabState extends State<NotesListTab> {
  int selectedIndex = -1;
  late String currentUserUid;

  void changeSelectedIndex(int newIndex) {
    setState(() {
      if (selectedIndex == newIndex) {
        selectedIndex = newIndex;
      } else {
        selectedIndex = -1;
      }
    });
  }

  bool isShowedMenu(int widgetId) {
    return widgetId == selectedIndex;
  }

  void loadCurrentUserId() {
    User? currentUser = FireAuth.getUser();
    currentUserUid = currentUser!.uid;
  }

  @override
  void initState() {
    loadCurrentUserId();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: widget.notesList.length + 1,
      itemBuilder: (BuildContext context, int index) {
        if (index <= widget.notesList.length - 1) {
          final noteData = widget.notesList[index];

          return NotesItemWidget(
            noteData: noteData,
            onDoubleTapToggle: () {
              if (mounted) {
                setState(() {
                  if (selectedIndex == index) {
                    selectedIndex = -1;
                  } else {
                    selectedIndex = index;
                  }
                });
              }
            }, // TODO
            mustShow: index == selectedIndex,
            onTapToggle: () => setState(() {
              selectedIndex = -1;
            }),
            userIsAuthor: noteData.note.author == currentUserUid,
          );
        } else {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Image.asset('assets/cat-3-512.png', height: 60),
              Image.asset('assets/kindpng_1052418.png', height: 40),
              Image.asset('assets/cat-3-512.png', height: 60),
              Image.asset('assets/kindpng_1052418.png', height: 40),
              Image.asset('assets/cat-3-512.png', height: 60),
              Image.asset('assets/kindpng_1052418.png', height: 40)
            ],
          );
        }
      },
    );
  }
}

class NotesItemWidget extends StatefulWidget {
  const NotesItemWidget({
    super.key,
    required this.noteData,
    required this.onDoubleTapToggle,
    required this.mustShow,
    required this.onTapToggle,
    required this.userIsAuthor,
  });

  final NoteData noteData;
  final bool mustShow;
  final VoidCallback onDoubleTapToggle;
  final VoidCallback onTapToggle;
  final bool userIsAuthor;

  @override
  State<NotesItemWidget> createState() => _NotesItemWidgetState();
}

class _NotesItemWidgetState extends State<NotesItemWidget> {
  late String authorName;

  @override
  void initState() {
    getAuthorName();
    super.initState();
  }

  getAuthorName() {
    setState(() {
      authorName = widget.noteData.note.getAuthorNameFromId();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          children: [
            InkWell(
              onDoubleTap:
                  widget.userIsAuthor ? () => widget.onDoubleTapToggle() : null,
              onTap: () {
                widget.onTapToggle();
                showModalBottomSheet(
                  backgroundColor: Colors.amber[100],
                  context: context,
                  builder: (context) => NotesModalWidget(
                    noteDataKey: widget.noteData.key,
                  ),
                );
              },
              child: Card(
                margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                color: Colors.amber[100],
                shape: const ContinuousRectangleBorder(),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: RichText(
                              softWrap: false,
                              text: TextSpan(
                                children: [
                                  WidgetSpan(
                                    child: widget.noteData.note
                                        .getWidgetFromState(),
                                    alignment: PlaceholderAlignment.middle,
                                  ),
                                  const WidgetSpan(
                                    child: SizedBox(
                                      width: 8,
                                    ),
                                  ),
                                  TextSpan(
                                    text: widget.noteData.note.title,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                      color: Colors.black,
                                      overflow: TextOverflow.fade,
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(authorName),
                              Text(widget.noteData.note.creationDate
                                  .formatToItalian()),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            widget.userIsAuthor
                ? Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        AnimatedSize(
                          curve: Curves.easeInOutCubicEmphasized,
                          duration: const Duration(milliseconds: 1000),
                          child: SizedBox(
                            width: widget.mustShow ? 137 : 0,
                            child: Row(
                              children: [
                                Container(
                                  height: 68.5,
                                  width: 68.5,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFB71C1C),
                                  ),
                                  child: IconButton(
                                    onPressed: () async {
                                      showDialog<void>(
                                        context: context,
                                        builder: (context) {
                                          return AlertDialog(
                                            title: const Text('Elimina nota'),
                                            content: const Text(
                                                'Vuoi davvero eliminare la nota?'),
                                            actions: [
                                              TextButton(
                                                onPressed: () async {
                                                  var callStatus =
                                                      await deleteNote(
                                                          key: widget
                                                              .noteData.key);
                                                  if (context.mounted) {
                                                    Navigator.of(context).pop();
                                                    if (callStatus ==
                                                        DatabaseCallStatus
                                                            .error) {
                                                      Navigator.of(context)
                                                          .pop();
                                                      showDialog(
                                                        context: context,
                                                        builder: (context) =>
                                                            AlertDialog(
                                                          title: const Text(
                                                              'Warning'),
                                                          content: const Text(
                                                              'Qualcosa è andato storto con il database.'),
                                                          actions: [
                                                            TextButton(
                                                              onPressed: () {
                                                                Navigator.of(
                                                                        context)
                                                                    .pop();
                                                              },
                                                              child: const Text(
                                                                  'Ok, capito'),
                                                            ),
                                                          ],
                                                        ),
                                                      );
                                                    }

                                                    widget.onTapToggle();
                                                  }
                                                },
                                                child: const Text('Conferma'),
                                              ),
                                              TextButton(
                                                onPressed: () =>
                                                    Navigator.of(context).pop(),
                                                child: const Text('Chiudi'),
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    },
                                    icon: const Icon(
                                      Icons.delete_outline,
                                    ),
                                    color: Colors.white,
                                  ),
                                ),
                                Container(
                                  height: 68.5,
                                  width: 68.5,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF1B5E20),
                                  ),
                                  child: IconButton(
                                    onPressed: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (ctx) => AddNoteScreen(
                                            updateMode: true,
                                            noteDataToUpdate: widget.noteData,
                                          ),
                                        ),
                                      );
                                    },
                                    icon: const Icon(
                                      Icons.mode,
                                    ),
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : const SizedBox(),
          ],
        ),
      ],
    );
  }
}
