import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_family_app/auth/fire_auth.dart';
import 'package:my_family_app/constants/app_constants.dart';
import 'package:my_family_app/models/recipe.dart';
import 'package:my_family_app/providers/recipe/ingredient_provider.dart';
import 'package:my_family_app/providers/recipe/step_provider.dart';
import 'package:my_family_app/screens/recipe/recipes_screen.dart';
import 'package:my_family_app/services/recipe_service.dart';
import 'package:my_family_app/utils/constants.dart';
import 'package:my_family_app/widgets/main_app_bar.dart';

class AddRecipeScreen extends ConsumerStatefulWidget {
  const AddRecipeScreen({
    super.key,
    required this.updateMode,
    this.recipeDataToUpdate,
  });

  final bool updateMode;
  final RecipeData? recipeDataToUpdate;

  @override
  ConsumerState<AddRecipeScreen> createState() => _AddRecipeScreenState();
}

class _AddRecipeScreenState extends ConsumerState<AddRecipeScreen> {
  final _formKey = GlobalKey<FormState>();

  late String? _authorUid;

  final TextEditingController _nameTextController = TextEditingController();
  final TextEditingController _quantityTextController = TextEditingController();
  final TextEditingController _unitMeasurementTextController =
      TextEditingController();

  final FocusNode ingredientNameInputFocus = FocusNode();
  final FocusNode stepInputFocus = FocusNode();

  void onRequestRefactoringIngredient(
      Ingredient ingredient, int indexToUpdate) {
    _nameTextController.text = ingredient.name;
    if (ingredient.quantity != -1) {
      _quantityTextController.text = ingredient.quantity.toString();
    }
    _unitMeasurementTextController.text = ingredient.unitMeasurement;
    updateIngredientMode = true;
    selectedIndexOfIngredient = indexToUpdate;

    FocusScope.of(context).requestFocus(ingredientNameInputFocus);
    setState(() {});
  }

  void onRequestRefactorStep(String step, int indexToUpdate) {
    _stepTextController.text = step;
    updateStepMode = true;
    selectedIndexOfStep = indexToUpdate;

    FocusScope.of(context).requestFocus(stepInputFocus);
    setState(() {});
  }

  final TextEditingController _titleTextController = TextEditingController();
  final TextEditingController _servingsTextController = TextEditingController();
  final TextEditingController _preparationTimeTextController =
      TextEditingController();
  final TextEditingController _stepTextController = TextEditingController();
  final TextEditingController _linkTextController = TextEditingController();

  bool updateIngredientMode = false;
  bool updateStepMode = false;
  int selectedIndexOfIngredient = -1;
  int selectedIndexOfStep = -1;
  bool isEnabledIngredientButton = false;
  bool isEnabledStepButton = false;

  void resetIngredientFields() {
    _nameTextController.text = '';
    _quantityTextController.text = '';
    _unitMeasurementTextController.text = '';
    isEnabledIngredientButton = false;

    resetUpdateIngredientMode();
  }

  void resetUpdateIngredientMode() {
    setState(() {
      updateIngredientMode = false;
    });
  }

  void resetStepField() {
    _stepTextController.text = '';
    isEnabledStepButton = false;

    resetUpdateStepMode();
  }

  void resetUpdateStepMode() {
    setState(() {
      updateStepMode = false;
    });
  }

  void toggleIngredientButton(value) {
    setState(() {
      isEnabledIngredientButton = value;
    });
  }

  void toggleStepButton(value) {
    setState(() {
      isEnabledStepButton = value;
    });
  }

  late Difficulty _selectedDifficulty;

  late RecipeData recipeData;

  @override
  void initState() {
    super.initState();

    if (widget.recipeDataToUpdate != null) {
      recipeData = widget.recipeDataToUpdate!;
      Recipe recipe = recipeData.recipe;

      _authorUid = recipe.author;
      _selectedDifficulty = recipe.difficulty;

      _titleTextController.text = recipe.title;

      if (recipe.servings != -1) {
        _servingsTextController.text = recipe.servings.toString();
      }

      if (recipe.preparationTime != -1) {
        _preparationTimeTextController.text = recipe.preparationTime.toString();
      }

      _linkTextController.text = recipe.externalLink;
    } else {
      User? currentUser = FireAuth.getUser();
      _authorUid = currentUser!.uid;
      _selectedDifficulty = Difficulty.easy;
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Ingredient> ingredientsList = ref.watch(ingredientListProvider);
    final List<String> stepsList = ref.watch(stepListProvider);

    return Scaffold(
      extendBody: true,
      appBar: const MainAppBar(
        mainTitle: appTitle,
        backgroundColor: AppBarColors.recipe,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Image.asset('assets/icons8-kawaii-bread-96.png', height: 30),
                  Image.asset('assets/icons8-kawaii-croissant-96.png',
                      height: 30),
                  Image.asset('assets/icons8-kawaii-french-fries-96.png',
                      height: 30),
                  Image.asset('assets/icons8-kawaii-noodle-96.png', height: 30),
                  Image.asset('assets/icons8-kawaii-pizza-96.png', height: 30),
                  Image.asset('assets/icons8-kawaii-steak-96.png', height: 30),
                  Image.asset('assets/icons8-kawaii-sushi-96.png', height: 30),
                ],
              ),
              const SizedBox(
                height: 12,
              ),
              Text(
                widget.updateMode
                    ? 'Modifica una ricetta'
                    : 'Aggiungi una ricetta',
                style: Theme.of(context).textTheme.headlineLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _titleTextController,
                      decoration: const InputDecoration(
                        filled: true,
                        hintText: 'Titolo',
                        fillColor: Color(0xFFE1F5FE),
                        label: Text('Titolo'),
                      ),
                    ),
                    const SizedBox(
                      height: 32,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Difficoltà:'),
                        const SizedBox(
                          width: 20,
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          decoration:
                              const BoxDecoration(color: Color(0xFFE1F5FE)),
                          child: DropdownButton(
                            dropdownColor: const Color(0xFFE1F5FE),
                            value: _selectedDifficulty,
                            items: [
                              for (final difficulty
                                  in difficultiesInItalian.entries)
                                DropdownMenuItem(
                                  value: difficulty.key,
                                  child: Text(difficulty.value),
                                )
                            ],
                            onChanged: (value) {
                              setState(() {
                                _selectedDifficulty = value!;
                              });
                            },
                            underline: Container(
                              height: 1,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 32,
                    ),
                    TextFormField(
                      controller: _servingsTextController,
                      decoration: const InputDecoration(
                        filled: true,
                        hintText: 'Per quante persone',
                        fillColor: Color(0xFFE1F5FE),
                        label: Text('Per quante persone'),
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                    ),
                    const SizedBox(
                      height: 32,
                    ),
                    TextFormField(
                      controller: _preparationTimeTextController,
                      decoration: const InputDecoration(
                        filled: true,
                        hintText: 'Tempo di preparazione',
                        suffix: Text('minuti'),
                        fillColor: Color(0xFFE1F5FE),
                        label: Text('Tempo di preparazione'),
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                    ),
                    const SizedBox(
                      height: 32,
                    ),
                    TextFormField(
                      controller: _linkTextController,
                      decoration: const InputDecoration(
                        filled: true,
                        hintText: 'Link alla ricetta (opzionale)',
                        fillColor: Color(0xFFE1F5FE),
                        label: Text('Link alla ricetta (opzionale)'),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Row(
                      children: [
                        const Expanded(
                            child: Divider(
                          thickness: 2,
                        )),
                        const SizedBox(
                          width: 4,
                        ),
                        Text(
                          'Ingredienti',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(
                          width: 4,
                        ),
                        const Expanded(
                            child: Divider(
                          thickness: 2,
                        ))
                      ],
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.lightBlueAccent,
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(15)),
                      child: ingredientsList.isEmpty
                          ? const Row(
                              children: [
                                Spacer(),
                                Text('Nessun ingrediente aggiunto'),
                                Spacer(),
                              ],
                            )
                          : ListView.builder(
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: ingredientsList.length,
                              itemBuilder: (_, index) {
                                Ingredient ingredient = ingredientsList[index];
                                return IngredientListItem(
                                  ingredient: ingredient,
                                  refactorIngredient:
                                      onRequestRefactoringIngredient,
                                  indexOfIngredient: index,
                                  resetIngredientFields: resetIngredientFields,
                                );
                              },
                            ),
                    ),
                    const SizedBox(
                      height: 32,
                    ),
                    IngredientsInput(
                      nameTextController: _nameTextController,
                      quantityTextController: _quantityTextController,
                      unitMeasurementTextController:
                          _unitMeasurementTextController,
                      ingredientNameInputFocus: ingredientNameInputFocus,
                      updateMode: updateIngredientMode,
                      indexToUpdate: selectedIndexOfIngredient,
                      resetIngredientFields: resetIngredientFields,
                      isEnabledButton: isEnabledIngredientButton,
                      toggleButton: toggleIngredientButton,
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Row(
                      children: [
                        const Expanded(
                            child: Divider(
                          thickness: 2,
                        )),
                        const SizedBox(
                          width: 4,
                        ),
                        Text(
                          'Steps',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(
                          width: 4,
                        ),
                        const Expanded(
                            child: Divider(
                          thickness: 2,
                        ))
                      ],
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.lightBlueAccent,
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(15)),
                      child: stepsList.isEmpty
                          ? const Row(
                              children: [
                                Spacer(),
                                Text('Nessuno step aggiunto'),
                                Spacer(),
                              ],
                            )
                          : ListView.builder(
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: stepsList.length,
                              itemBuilder: (_, index) {
                                String step = stepsList[index];
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                    horizontal: 4,
                                  ),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Expanded(
                                        child: RichText(
                                          text: TextSpan(
                                            style: const TextStyle(
                                              color: Colors.black,
                                              fontSize: 18,
                                            ),
                                            children: [
                                              TextSpan(
                                                text: '${index + 1} - ',
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              TextSpan(
                                                text: step,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      IconButton(
                                        onPressed: () {
                                          onRequestRefactorStep(step, index);
                                        },
                                        icon: const Icon(
                                          Icons.mode,
                                          color: Color(0xFF00796B),
                                        ),
                                      ),
                                      IconButton(
                                        onPressed: () {
                                          ref
                                              .read(stepListProvider.notifier)
                                              .removeStep(index);

                                          resetStepField();
                                        },
                                        icon: const Icon(
                                          Icons.delete,
                                          color: Color(0xFFB71C1C),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                    ),
                    const SizedBox(
                      height: 32,
                    ),
                    StepInput(
                      stepTextController: _stepTextController,
                      stepInputFocus: stepInputFocus,
                      updateStepMode: updateStepMode,
                      selectedIndexOfStep: selectedIndexOfStep,
                      resetStepFields: resetStepField,
                      isEnabledButton: isEnabledStepButton,
                      toggleButton: toggleStepButton,
                    ),
                    const SizedBox(
                      height: 32,
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Image.asset('assets/icons8-kawaii-bread-96.png', height: 30),
                  Image.asset('assets/icons8-kawaii-croissant-96.png',
                      height: 30),
                  Image.asset('assets/icons8-kawaii-french-fries-96.png',
                      height: 30),
                  Image.asset('assets/icons8-kawaii-noodle-96.png', height: 30),
                  Image.asset('assets/icons8-kawaii-pizza-96.png', height: 30),
                  Image.asset('assets/icons8-kawaii-steak-96.png', height: 30),
                  Image.asset('assets/icons8-kawaii-sushi-96.png', height: 30),
                ],
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'add_recipe',
        elevation: 12,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(36),
        ),
        backgroundColor: Colors.blue,
        onPressed: () async {
          var title = _titleTextController.text.trim();
          var difficulty = _selectedDifficulty;
          int servings = int.tryParse(_servingsTextController.text) ?? -1;
          int preparationTime =
              int.tryParse(_preparationTimeTextController.text) ?? -1;
          var externalLink = _linkTextController.text;

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
          } else if (ingredientsList.isEmpty) {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Warning'),
                content: RichText(
                  text: const TextSpan(
                    style: TextStyle(color: Colors.black, height: 1.5),
                    children: [
                      TextSpan(
                        text: 'Non hai inserito nessun ingrediente!!!',
                      ),
                      TextSpan(
                        text: 'Inseriscine almeno uno',
                      ),
                    ],
                  ),
                ),
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
          } else if (stepsList.isEmpty) {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Warning'),
                content: RichText(
                  text: const TextSpan(
                    style: TextStyle(color: Colors.black, height: 1.5),
                    children: [
                      TextSpan(
                        text: 'Non hai inserito nessuno step!!! ',
                      ),
                      TextSpan(
                        text: 'Inseriscine almeno uno',
                      ),
                    ],
                  ),
                ),
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
            Recipe newRecipe = Recipe(
              title: title,
              author: _authorUid!,
              difficulty: difficulty,
              servings: servings,
              preparationTime: preparationTime,
              ingredients: ingredientsList,
              steps: stepsList,
              externalLink: externalLink,
            );

            DatabaseCallStatus callStatus;

            if (widget.updateMode) {
              RecipeData updatedRecipeData =
                  RecipeData(key: recipeData.key, recipe: newRecipe);
              callStatus = await updateRecipe(newRecipeData: updatedRecipeData);
            } else {
              callStatus = await createRecipe(newRecipe: newRecipe);
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
                    builder: (context) => const RecipesScreen(),
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
    _nameTextController.dispose();
    _quantityTextController.dispose();
    _unitMeasurementTextController.dispose();

    _titleTextController.dispose();
    _servingsTextController.dispose();
    _preparationTimeTextController.dispose();
    _stepTextController.dispose();
    _linkTextController.dispose();

    ingredientNameInputFocus.dispose();
    stepInputFocus.dispose();

    super.dispose();
  }
}

class IngredientListItem extends ConsumerWidget {
  const IngredientListItem({
    super.key,
    required this.ingredient,
    required this.refactorIngredient,
    required this.indexOfIngredient,
    required this.resetIngredientFields,
  });

  final Ingredient ingredient;
  final void Function(Ingredient ingredient, int indexToUpdate)
      refactorIngredient;
  final int indexOfIngredient;
  final void Function() resetIngredientFields;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.circle_sharp,
            size: 10,
          ),
          const SizedBox(
            width: 6,
          ),
          Expanded(
            child: RichText(
              overflow: TextOverflow.ellipsis,
              text: TextSpan(
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                ),
                children: [
                  TextSpan(
                    text: ingredient.name,
                    style: const TextStyle(
                      decoration: TextDecoration.underline,
                    ),
                  ),
                  const WidgetSpan(
                    child: SizedBox(
                      width: 12,
                    ),
                  ),
                  if (ingredient.quantity != -1)
                    TextSpan(
                      text: ingredient.quantity.toString(),
                    ),
                  const WidgetSpan(
                    child: SizedBox(
                      width: 6,
                    ),
                  ),
                  TextSpan(
                    text: ingredient.unitMeasurement,
                  ),
                ],
              ),
            ),
          ),
          IconButton(
            onPressed: () {
              refactorIngredient(ingredient, indexOfIngredient);
            },
            icon: const Icon(
              Icons.mode,
              color: Color(0xFF00796B),
            ),
          ),
          IconButton(
            onPressed: () {
              ref
                  .read(ingredientListProvider.notifier)
                  .removeIngredient(indexOfIngredient);

              resetIngredientFields();
            },
            icon: const Icon(
              Icons.delete,
              color: Color(0xFFB71C1C),
            ),
          ),
        ],
      ),
    );
  }
}

class IngredientsInput extends ConsumerStatefulWidget {
  const IngredientsInput({
    super.key,
    required this.nameTextController,
    required this.quantityTextController,
    required this.unitMeasurementTextController,
    required this.ingredientNameInputFocus,
    required this.updateMode,
    required this.indexToUpdate,
    required this.resetIngredientFields,
    required this.isEnabledButton,
    required this.toggleButton,
  });

  final TextEditingController nameTextController;
  final TextEditingController quantityTextController;
  final TextEditingController unitMeasurementTextController;
  final FocusNode ingredientNameInputFocus;
  final bool updateMode;
  final int indexToUpdate;
  final void Function() resetIngredientFields;
  final bool isEnabledButton;
  final void Function(bool value) toggleButton;

  @override
  ConsumerState<IngredientsInput> createState() => _IngredientsInputState();
}

class _IngredientsInputState extends ConsumerState<IngredientsInput> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextFormField(
          controller: widget.nameTextController,
          focusNode: widget.ingredientNameInputFocus,
          onChanged: (_) {
            if (!widget.isEnabledButton &&
                widget.nameTextController.text != '') {
              widget.toggleButton(true);
            } else if (widget.nameTextController.text == '') {
              widget.toggleButton(false);
            }
          },
          decoration: const InputDecoration(
            filled: true,
            hintText: 'Nome dell\'ingrediente',
            fillColor: Color(0xFFE1F5FE),
            label: Text('Nome dell\'ingrediente'),
          ),
        ),
        const SizedBox(
          height: 20,
        ),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: widget.quantityTextController,
                onChanged: (_) {
                  if (!widget.isEnabledButton &&
                      widget.nameTextController.text != '') {
                    widget.toggleButton(true);
                  }
                },
                decoration: const InputDecoration(
                  filled: true,
                  hintText: 'Quantità',
                  fillColor: Color(0xFFE1F5FE),
                  label: Text('Quantità'),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
            ),
            const SizedBox(
              width: 12,
            ),
            Expanded(
              child: TextFormField(
                controller: widget.unitMeasurementTextController,
                onChanged: (_) {
                  if (!widget.isEnabledButton &&
                      widget.nameTextController.text != '') {
                    widget.toggleButton(true);
                  }
                },
                decoration: const InputDecoration(
                  filled: true,
                  hintText: 'Unità di misura',
                  fillColor: Color(0xFFE1F5FE),
                  label: Text('Unità di misura'),
                ),
              ),
            )
          ],
        ),
        const SizedBox(
          height: 10,
        ),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: !widget.isEnabledButton
                    ? null
                    : () {
                        FocusScope.of(context)
                            .requestFocus(widget.ingredientNameInputFocus);

                        if (widget.nameTextController.text == '') {
                          return;
                        }

                        Ingredient newIngredient = Ingredient(
                          name: widget.nameTextController.text,
                          quantity: int.tryParse(
                                  widget.quantityTextController.text) ??
                              -1,
                          unitMeasurement:
                              widget.unitMeasurementTextController.text,
                        );

                        bool response;

                        if (widget.updateMode) {
                          response = ref
                              .read(ingredientListProvider.notifier)
                              .update(newIngredient, widget.indexToUpdate);
                        } else {
                          response = ref
                              .read(ingredientListProvider.notifier)
                              .addIngredient(newIngredient);
                        }

                        if (response == false) {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: const Text(
                                    'Attenzione. Hai già questo ingrediente!!!'),
                                content: const Text('Controlla la lista sopra'),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: const Text('Ok, capito'),
                                  ),
                                ],
                              );
                            },
                          );

                          return;
                        }

                        widget.resetIngredientFields();
                      },
                icon: const Icon(Icons.add),
                label: Text(widget.updateMode ? 'Modifica' : 'Aggiungi'),
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.resolveWith((states) {
                    if (states.contains(MaterialState.disabled)) {
                      return Theme.of(context)
                          .colorScheme
                          .primary
                          .withOpacity(0.5);
                    }
                    return Theme.of(context).colorScheme.primary;
                  }),
                ),
              ),
            ),
            const SizedBox(
              width: 12,
            ),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => widget.resetIngredientFields(),
                icon: const Icon(Icons.cleaning_services_sharp),
                label: const Text('Reset'),
                style: const ButtonStyle(
                  backgroundColor: MaterialStatePropertyAll(
                    Colors.amber,
                  ),
                  foregroundColor: MaterialStatePropertyAll(
                    Colors.black,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class StepInput extends ConsumerStatefulWidget {
  const StepInput({
    super.key,
    required this.stepTextController,
    required this.stepInputFocus,
    required this.updateStepMode,
    required this.selectedIndexOfStep,
    required this.resetStepFields,
    required this.isEnabledButton,
    required this.toggleButton,
  });

  final TextEditingController stepTextController;
  final FocusNode stepInputFocus;
  final bool updateStepMode;
  final int selectedIndexOfStep;
  final void Function() resetStepFields;
  final bool isEnabledButton;
  final void Function(bool value) toggleButton;

  @override
  ConsumerState<StepInput> createState() => _StepInputState();
}

class _StepInputState extends ConsumerState<StepInput> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextFormField(
          controller: widget.stepTextController,
          focusNode: widget.stepInputFocus,
          onChanged: (_) {
            if (!widget.isEnabledButton &&
                widget.stepTextController.text != '') {
              widget.toggleButton(true);
            } else if (widget.stepTextController.text == '') {
              widget.toggleButton(false);
            }
          },
          keyboardType: TextInputType.multiline,
          maxLines: null,
          decoration: const InputDecoration(
            filled: true,
            hintText: 'Step di preparazione',
            fillColor: Color(0xFFE1F5FE),
            label: Text('Step di preparazione'),
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: !widget.isEnabledButton
                    ? null
                    : () {
                        FocusScope.of(context)
                            .requestFocus(widget.stepInputFocus);

                        if (widget.stepTextController.text == '') {
                          return;
                        }
                        String newStep = widget.stepTextController.text;

                        if (widget.updateStepMode) {
                          ref
                              .read(stepListProvider.notifier)
                              .updateStep(newStep, widget.selectedIndexOfStep);
                        } else {
                          ref.read(stepListProvider.notifier).addStep(newStep);
                        }

                        // widget.stepTextController.text = '';
                        widget.resetStepFields();
                      },
                icon: const Icon(Icons.add),
                label: Text(widget.updateStepMode ? 'Modifica' : 'Aggiungi'),
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.resolveWith((states) {
                    if (states.contains(MaterialState.disabled)) {
                      return Theme.of(context)
                          .colorScheme
                          .primary
                          .withOpacity(0.5);
                    }
                    return Theme.of(context).colorScheme.primary;
                  }),
                ),
              ),
            ),
            const SizedBox(
              width: 12,
            ),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => widget.resetStepFields(),
                icon: const Icon(Icons.cleaning_services_sharp),
                label: const Text('Reset'),
                style: const ButtonStyle(
                  backgroundColor: MaterialStatePropertyAll(
                    Colors.amber,
                  ),
                  foregroundColor: MaterialStatePropertyAll(
                    Colors.black,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
