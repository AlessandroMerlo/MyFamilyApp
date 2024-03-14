import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_family_app/data/database.dart';
import 'package:my_family_app/models/note.dart';

const String path = 'notes';

final DatabaseReference _databaseRef = FireBaseRealTimeDatabase.database.ref();

final noteStreamProvider = StreamProvider<List<NoteData>>((ref) {
  final streamController = StreamController<List<NoteData>>();

  final notesList = <NoteData>[];

  Query query = _databaseRef.child(path);

  query.onChildAdded.listen((event) {
    Note note = Note.fromJson(event.snapshot.value as Map);
    NoteData noteData = NoteData(key: event.snapshot.key!, note: note);

    notesList.add(noteData);
    streamController.add(notesList);
  });

  query.onChildRemoved.listen((event) {
    notesList.removeWhere((element) => element.key == event.snapshot.key);
    streamController.add(notesList);
  });

  query.onChildChanged.listen((event) {
    Note updatedNote = Note.fromJson(event.snapshot.value as Map);
    NoteData updatedNoteData =
        NoteData(key: event.snapshot.key!, note: updatedNote);

    int indexOf =
        notesList.indexWhere((element) => element.key == event.snapshot.key);

    if (indexOf != -1) {
      notesList[indexOf] = updatedNoteData;
      streamController.add(notesList);
    }
  });

  return streamController.stream;
});
