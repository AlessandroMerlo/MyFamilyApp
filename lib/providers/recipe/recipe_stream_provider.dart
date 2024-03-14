import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_family_app/data/database.dart';
import 'package:my_family_app/models/recipe.dart';

const String path = 'recipes';

final DatabaseReference _databaseRef = FireBaseRealTimeDatabase.database.ref();

final recipeStreamProvider = StreamProvider<List<RecipeData>>((ref) {
  final streamController = StreamController<List<RecipeData>>();

  final recipesList = <RecipeData>[];

  Query query = _databaseRef.child(path);

  query.onChildAdded.listen((event) {
    Recipe recipe = Recipe.fromJson(event.snapshot.value as Map);
    RecipeData recipeData =
        RecipeData(key: event.snapshot.key!, recipe: recipe);

    recipesList.add(recipeData);
    streamController.add(recipesList);
  });

  query.onChildRemoved.listen((event) {
    recipesList.removeWhere((element) => element.key == event.snapshot.key);
    streamController.add(recipesList);
  });

  query.onChildChanged.listen((event) {
    Recipe updatedRecipe = Recipe.fromJson(event.snapshot.value as Map);
    RecipeData updatedRecipeData =
        RecipeData(key: event.snapshot.key!, recipe: updatedRecipe);

    int indexOf =
        recipesList.indexWhere((element) => element.key == event.snapshot.key);

    if (indexOf != -1) {
      recipesList[indexOf] = updatedRecipeData;
      streamController.add(recipesList);
    }
  });

  return streamController.stream;
});
