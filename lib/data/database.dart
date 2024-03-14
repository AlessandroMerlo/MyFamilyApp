import 'package:firebase_database/firebase_database.dart';
import 'package:my_family_app/models/note.dart';
import 'package:my_family_app/models/recipe.dart';
import 'package:my_family_app/models/users.dart';
import 'package:my_family_app/utils/constants.dart';

enum CallStatus { ok, error }

class FireBaseRealTimeDatabase {
  static final database = FirebaseDatabase.instance;

  static final List<MyUser> usersList = [];

  static Future<void> loadUsers() async {
    var users = await FireBaseRealTimeDatabase.getUsers();
    for (var user in users.values) {
      usersList.add(MyUser.fromJson(user));
    }
  }

  // static Future<void> saveUser({required MyUser user}) async {
  //   await database.ref().child('users').push().set(user.toJson());
  // }

  static Future<Map<dynamic, dynamic>> getUsers() async {
    var snapshot = await database.ref().child('users').once();

    return Map<dynamic, dynamic>.from(snapshot.snapshot.value as Map);
  }

  static Future<DatabaseCallStatus> create({
    required String path,
    required Map<String, Object> newObject,
  }) async {
    try {
      database.ref().child(path).push().set(newObject);
      return DatabaseCallStatus.ok;
    } on Error catch (_) {
      return DatabaseCallStatus.error;
    }
  }

  static Future<DatabaseCallStatus> update({
    required String path,
    required String key,
    required Map<String, Object> newObject,
  }) async {
    try {
      database.ref().child(path).child(key).update(newObject);
      return DatabaseCallStatus.ok;
    } on Error catch (_) {
      return DatabaseCallStatus.error;
    }
  }

  static Future<DatabaseCallStatus> delete(
      {required String path, required String key}) async {
    try {
      database.ref().child(path).child(key).remove();
      return DatabaseCallStatus.ok;
    } on Error catch (_) {
      return DatabaseCallStatus.error;
    }
  }

  static Future<List<NoteData>> getNotesList() async {
    List<NoteData> response = [];

    var snapshot = await database.ref().child('notes').once();
    Map notesData = Map<String, dynamic>.from(snapshot.snapshot.value as Map);

    for (var noteData in notesData.entries) {
      Note nota = Note.fromJson(noteData.value as Map);
      NoteData noteDataToAdd = NoteData(key: noteData.key, note: nota);
      response.add(noteDataToAdd);
    }

    return response;
  }

  static Future<List<RecipeData>> getRecipesList() async {
    List<RecipeData> response = [];

    var snapshot = await database.ref().child('recipes').once();
    Map recipesData = Map<String, dynamic>.from(snapshot.snapshot.value as Map);

    for (var recipeData in recipesData.entries) {
      Recipe recipe = Recipe.fromJson(recipeData.value as Map);
      RecipeData recipeDataToAdd =
          RecipeData(key: recipeData.key, recipe: recipe);
      response.add(recipeDataToAdd);
    }

    return response;
  }

}
