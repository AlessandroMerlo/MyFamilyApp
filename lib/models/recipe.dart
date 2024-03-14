import 'package:my_family_app/services/user_service.dart';

enum Difficulty {
  easy,
  medium,
  hard,
}

Map<Difficulty, String> difficultiesInItalian = {
  Difficulty.easy: 'Facile',
  Difficulty.medium: 'Media',
  Difficulty.hard: 'Difficile'
};

String getItalianWordFromDifficulty(Difficulty difficulty) =>
    difficultiesInItalian[difficulty]!;

class RecipeData {
  final String key;
  final Recipe recipe;

  RecipeData({
    required this.key,
    required this.recipe,
  });
}

class Recipe {
  final String title;
  final String author;
  final Difficulty difficulty;
  final int servings;
  final int preparationTime;
  final List<Ingredient> ingredients;
  final List<String> steps;
  final String externalLink;

  Recipe({
    required this.title,
    required this.author,
    required this.difficulty,
    required this.servings,
    required this.preparationTime,
    required this.ingredients,
    required this.steps,
    required this.externalLink,
  });

  String getItalianWord() => getItalianWordFromDifficulty(difficulty);

  Recipe.fromJson(Map<dynamic, dynamic> json)
      : title = json['title'],
        author = json['author'],
        difficulty = Difficulty.values.byName(json['difficulty']),
        servings = json['servings'],
        preparationTime = json['preparationTime'],
        ingredients = [
          for (final ingredient in json['ingredients'])
            Ingredient.fromJson(ingredient as Map)
        ],
        steps = List.from(json['steps']),
        externalLink = json['externalLink'];

  Map<String, Object> toJson() => {
        'title': title,
        'author': author,
        'difficulty': difficulty.name,
        'servings': servings,
        'preparationTime': preparationTime,
        'ingredients':
            ingredients.map((ingredient) => ingredient.toJson()).toList(),
        'steps': steps,
        'externalLink': externalLink,
      };

  String getAuthorNameFromId() {
    return myUsersList.firstWhere((user) => user.id == author).name;
  }
}

class Ingredient {
  final String name;
  final int quantity;
  final String unitMeasurement;

  Ingredient({
    required this.name,
    required this.quantity,
    required this.unitMeasurement,
  });

  Ingredient.fromJson(Map<dynamic, dynamic> json)
      : name = json['name'],
        quantity = json['quantity'],
        unitMeasurement = json['unitMeasurement'];

  Map<String, Object> toJson() => {
        'name': name,
        'quantity': quantity,
        'unitMeasurement': unitMeasurement,
      };
}
