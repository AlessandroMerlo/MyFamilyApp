import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_family_app/models/recipe.dart';

class IngredientListNotifier extends StateNotifier<List<Ingredient>> {
  IngredientListNotifier() : super([]);

  bool addIngredient(Ingredient ingredient) {
    int indexOf = state.indexWhere((el) => el.name == ingredient.name);

    if (indexOf != -1) {
      return false;
    }

    state = [...state, ingredient];

    return true;
  }

  void removeIngredient(int index) {
    state = [
      for (int i = 0; i < state.length; i++)
        if (i != index) state[i]
    ];
  }

  bool update(Ingredient ingredient, int index) {
    int indexOf = state.indexWhere((el) => el.name == ingredient.name);

    if (indexOf != -1 && indexOf != index) {
      return false;
    }

    state = [
      for (int i = 0; i < state.length; i++)
        if (i != index) state[i] else ingredient
    ];

    return true;
  }

  void addAllIngredient(List<Ingredient> ingredientList) {
    state = ingredientList;
  }

  void drainList() {
    state = [];
  }
}

final ingredientListProvider =
    StateNotifierProvider<IngredientListNotifier, List<Ingredient>>(
        (ref) => IngredientListNotifier());
