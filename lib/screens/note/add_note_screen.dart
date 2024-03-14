import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:my_family_app/auth/fire_auth.dart';
import 'package:my_family_app/constants/app_constants.dart';
import 'package:my_family_app/models/note.dart';
import 'package:my_family_app/screens/note/notes_screen.dart';
import 'package:my_family_app/services/note_service.dart';
import 'package:my_family_app/utils/constants.dart';
import 'package:my_family_app/widgets/main_app_bar.dart';

class AddNoteScreen extends StatefulWidget {
  const AddNoteScreen({
    super.key,
    required this.updateMode,
    this.noteDataToUpdate,
  });

  final bool updateMode;
  final NoteData? noteDataToUpdate;

  @override
  State<AddNoteScreen> createState() => _AddNoteScreenState();
}

class _AddNoteScreenState extends State<AddNoteScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleTextController = TextEditingController();
  final TextEditingController _bodyTextController = TextEditingController();

  NoteState _selectedState = NoteState.noState;

  void _changeSelectedState({required NoteState pressedState}) {
    if (_selectedState != pressedState) {
      setState(() {
        _selectedState = pressedState;
      });
    }
  }

  late String? _author;
  late String? _authorUid;

  late NoteData noteData;

  @override
  void initState() {
    super.initState();

    if (widget.noteDataToUpdate != null) {
      noteData = widget.noteDataToUpdate!;
      Note note = noteData.note;
      _authorUid = note.author;
      _author = note.getAuthorNameFromId();

      _selectedState = note.state!;

      _titleTextController.text = note.title;
      _bodyTextController.text = note.body;
    } else {
      User? currentUser = FireAuth.getUser();
      _authorUid = currentUser!.uid;
      _author = currentUser.displayName!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      appBar: const MainAppBar(
        mainTitle: appTitle,
        backgroundColor: AppBarColors.note,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                widget.updateMode ? 'Modifica una nota' : 'Aggiungi una nota',
                style: Theme.of(context).textTheme.headlineLarge,
                textAlign: TextAlign.center,
              ),
              // const SizedBox(height: 24),
              const Divider(
                color: Colors.teal,
                thickness: 1,
                height: 32,
              ),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    const Text(
                      'Stato:',
                      style: TextStyle(fontSize: 24),
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                          child: Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    width: 3,
                                    color: _selectedState == NoteState.noState
                                        ? Colors.teal
                                        : Colors.transparent,
                                  ),
                                  shape: BoxShape.circle,
                                ),
                                child: IconButton(
                                  onPressed: () {
                                    _changeSelectedState(
                                        pressedState: NoteState.noState);
                                  },
                                  icon: Transform.scale(
                                    scale: 1.4,
                                    child: getWidgetStateFromMap(
                                        NoteState.noState),
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 8,
                              ),
                              Text(_selectedState == NoteState.noState
                                  ? getItalianStringFromNoteState(
                                      NoteState.noState)
                                  : ''),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    width: 3,
                                    color: _selectedState == NoteState.done
                                        ? Colors.teal
                                        : Colors.transparent,
                                  ),
                                  shape: BoxShape.circle,
                                ),
                                child: IconButton(
                                  onPressed: () {
                                    _changeSelectedState(
                                        pressedState: NoteState.done);
                                  },
                                  icon: Transform.scale(
                                    scale: 1.4,
                                    child:
                                        getWidgetStateFromMap(NoteState.done),
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 8,
                              ),
                              Text(_selectedState == NoteState.done
                                  ? getItalianStringFromNoteState(
                                      NoteState.done)
                                  : ''),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    width: 3,
                                    color:
                                        _selectedState == NoteState.inProgress
                                            ? Colors.teal
                                            : Colors.transparent,
                                  ),
                                  shape: BoxShape.circle,
                                ),
                                child: IconButton(
                                  onPressed: () {
                                    _changeSelectedState(
                                        pressedState: NoteState.inProgress);
                                  },
                                  icon: Transform.scale(
                                    scale: 1.4,
                                    child: getWidgetStateFromMap(
                                        NoteState.inProgress),
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 8,
                              ),
                              Text(
                                _selectedState == NoteState.inProgress
                                    ? getItalianStringFromNoteState(
                                        NoteState.inProgress)
                                    : '',
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 32,
                    ),
                    TextFormField(
                      controller: _titleTextController,
                      decoration: const InputDecoration(
                        hintText: 'Titolo',
                      ),
                    ),
                    const SizedBox(
                      height: 32,
                    ),
                    TextFormField(
                      controller: _bodyTextController,
                      keyboardType: TextInputType.multiline,
                      maxLines: null,
                      decoration: const InputDecoration(
                        hintText: 'Contenuto',
                      ),
                    ),
                    const SizedBox(
                      height: 32,
                    ),
                    _author != null
                        ? Align(
                            alignment: Alignment.centerLeft,
                            child: Text.rich(
                              TextSpan(
                                text: 'Autore: ',
                                style: const TextStyle(
                                  fontSize: 18,
                                ),
                                children: [
                                  TextSpan(
                                    text: _author,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : const CircularProgressIndicator(),
                    const SizedBox(
                      height: 40,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'add_note',
        elevation: 12,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(36),
        ),
        backgroundColor: Colors.teal,
        onPressed: () async {
          var title = _titleTextController.text.trim();
          var body = _bodyTextController.text.trim();

          if (title == '') {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Warning'),
                content: const Text('Devi inserire il titolo!!!'),
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
          } else if (body == '') {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Warning'),
                content: const Text('Devi inserire il contenuto!!!'),
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
          } else {
            Note newNote = Note.withoutId(
              author: _authorUid!,
              state: _selectedState,
              title: title,
              body: body,
            );
            DatabaseCallStatus callStatus;

            if (widget.updateMode) {
              NoteData updatedNoteData =
                  NoteData(key: noteData.key, note: newNote);
              callStatus = await updateNote(newNoteData: updatedNoteData);
            } else {
              callStatus = await createNote(newNote: newNote);
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
                    builder: (context) => const NotesScreen(),
                  ),
                  (Route<dynamic> route) => false,
                );
              }
            }
          }
        },
        label: const Text(
          'Salva',
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleTextController.dispose();
    _bodyTextController.dispose();

    super.dispose();
  }
}
