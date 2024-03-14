import 'package:my_family_app/data/database.dart';
import 'package:my_family_app/models/note.dart';
import 'package:my_family_app/utils/constants.dart';

const String path = 'notes';

Future<DatabaseCallStatus> createNote({required Note newNote}) async {
  return await FireBaseRealTimeDatabase.create(
    path: path,
    newObject: newNote.toJson(),
  );
}

Future<DatabaseCallStatus> updateNote({required NoteData newNoteData}) async {
  return await FireBaseRealTimeDatabase.update(
    path: path,
    key: newNoteData.key,
    newObject: newNoteData.note.toJson(),
  );
}

Future<DatabaseCallStatus> deleteNote({required String key}) async {
  return await FireBaseRealTimeDatabase.delete(
    path: path,
    key: key,
  );
}
