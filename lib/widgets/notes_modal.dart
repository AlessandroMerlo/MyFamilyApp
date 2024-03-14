import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_family_app/auth/fire_auth.dart';
import 'package:my_family_app/extensions/date_time_x.dart';
import 'package:my_family_app/providers/note/note_stream_provider.dart';
import 'package:my_family_app/screens/note/add_note_screen.dart';
import 'package:my_family_app/services/note_service.dart';
import 'package:my_family_app/utils/constants.dart';

import '../components/faboulous_button.dart';
import '../models/note.dart';
import '../screens/note/details_note_screen.dart';

class NotesModalWidget extends StatefulWidget {
  const NotesModalWidget({
    super.key,
    required this.noteDataKey,
  });

  final String noteDataKey;

  @override
  State<NotesModalWidget> createState() => _NotesModalWidgetState();
}

class _NotesModalWidgetState extends State<NotesModalWidget> {
  late NoteData? noteData;

  void _showAction(BuildContext context, int index) {
    if (noteData != null) {
      switch (index) {
        case 0:
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (ctx) => DetailsNoteScreen(
                noteDataKey: noteData!.key,
              ),
            ),
          );
        case 1:
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (ctx) => AddNoteScreen(
                updateMode: true,
                noteDataToUpdate: noteData,
              ),
            ),
          );
        case 2:
          showDialog<void>(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text('Elimina nota'),
                content: const Text('Vuoi davvero eliminare la nota?'),
                actions: [
                  TextButton(
                    onPressed: () async {
                      var callStatus = await deleteNote(key: noteData!.key);
                      if (context.mounted) {
                        Navigator.of(context).pop();
                        Navigator.of(context).pop();
                        if (callStatus == DatabaseCallStatus.error) {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Warning'),
                              content: const Text(
                                  'Qualcosa è andato storto con il database.'),
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
                      }
                    },
                    child: const Text('Conferma'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Chiudi'),
                  ),
                ],
              );
            },
          );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.amber[100],
      body: Consumer(builder: (context, ref, child) {
        noteData = ref
            .watch(noteStreamProvider)
            .value!
            .firstWhereOrNull((element) => element.key == widget.noteDataKey);

        if (noteData != null) {
          final note = noteData!.note;
          return SizedBox(
            height: double.infinity,
            width: double.infinity,
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: note.getWidgetFromState(),
                ),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 70),
                          child: Text(
                            textAlign: TextAlign.center,
                            note.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 22,
                              color: Colors.black,
                              overflow: TextOverflow.fade,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Text(
                              '${note.getAuthorNameFromId()} - ${note.creationDate.formatToItalian()}'),
                        ),
                        Flexible(
                          child: SingleChildScrollView(
                            physics: const BouncingScrollPhysics(),
                            child: Text(
                              note.body,
                              style: const TextStyle(fontSize: 18, height: 1.5),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                FabulousButton(
                  onClickButton: _showAction,
                  isOwner: note.author == FireAuth.getUser()!.uid,
                ),
              ],
            ),
          );
        } else {
          Future.delayed(Duration.zero, () {
            const snackbar = SnackBar(
              content: Text(
                'Qualcuno ha cancellato la nota',
                textScaleFactor: 1.3,
              ),
              duration: Duration(seconds: 5),
              padding: EdgeInsets.all(24),
              elevation: 8,
            );

            ScaffoldMessenger.of(context).showSnackBar(snackbar);
          }).then((_) => Timer(const Duration(seconds: 5), () {
                Navigator.of(context).pop();
              }));
          return const Center(
            child: SingleChildScrollView(
                child: Center(child: CircularProgressIndicator())),
          );
        }
      }),
    );
  }
}
