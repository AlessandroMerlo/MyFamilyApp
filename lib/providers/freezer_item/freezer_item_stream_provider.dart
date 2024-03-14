import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_family_app/data/database.dart';
import 'package:my_family_app/models/freezer_item.dart';

const String path = 'freezer_items';

final DatabaseReference _databaseRef = FireBaseRealTimeDatabase.database.ref();

final freezerItemsStreamProvider = StreamProvider<List<FreezerItemData>>((ref) {
  final streamController = StreamController<List<FreezerItemData>>();

  final freezerItemsList = <FreezerItemData>[];

  Query query = _databaseRef.child(path);

  query.onChildAdded.listen((event) {
    FreezerItem note = FreezerItem.fromJson(event.snapshot.value as Map);
    FreezerItemData noteData =
        FreezerItemData(key: event.snapshot.key!, freezerItem: note);

    freezerItemsList.add(noteData);
    freezerItemsList.sort((a, b) =>
        a.freezerItem.expirationDate.compareTo(b.freezerItem.expirationDate));
    streamController.add(freezerItemsList);
  });

  query.onChildRemoved.listen((event) {
    freezerItemsList
        .removeWhere((element) => element.key == event.snapshot.key);
    streamController.add(freezerItemsList);
  });

  query.onChildChanged.listen((event) {
    FreezerItem updatedNote = FreezerItem.fromJson(event.snapshot.value as Map);
    FreezerItemData updatedNoteData =
        FreezerItemData(key: event.snapshot.key!, freezerItem: updatedNote);

    int indexOf = freezerItemsList
        .indexWhere((element) => element.key == event.snapshot.key);

    if (indexOf != -1) {
      freezerItemsList[indexOf] = updatedNoteData;
      freezerItemsList.sort((a, b) =>
          a.freezerItem.expirationDate.compareTo(b.freezerItem.expirationDate));
      streamController.add(freezerItemsList);
    }
  });

  return streamController.stream;
});
