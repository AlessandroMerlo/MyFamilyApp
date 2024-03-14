import 'package:my_family_app/data/database.dart';
import 'package:my_family_app/models/recipe.dart';
import 'package:my_family_app/utils/constants.dart';

const String path = 'recipes';

Future<DatabaseCallStatus> createRecipe({required Recipe newRecipe}) async {
  return await FireBaseRealTimeDatabase.create(
    path: path,
    newObject: newRecipe.toJson(),
  );
}

Future<DatabaseCallStatus> updateRecipe(
    {required RecipeData newRecipeData}) async {
  return await FireBaseRealTimeDatabase.update(
    path: path,
    key: newRecipeData.key,
    newObject: newRecipeData.recipe.toJson(),
  );
}

Future<DatabaseCallStatus> deleteRecipe({required String key}) async {
  return await FireBaseRealTimeDatabase.delete(
    path: path,
    key: key,
  );
}
