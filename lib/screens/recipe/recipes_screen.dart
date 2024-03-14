import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_family_app/auth/fire_auth.dart';
import 'package:my_family_app/constants/app_constants.dart';
import 'package:my_family_app/models/recipe.dart';
import 'package:my_family_app/models/users.dart';
import 'package:my_family_app/providers/recipe/ingredient_provider.dart';
import 'package:my_family_app/providers/recipe/recipe_stream_provider.dart';
import 'package:my_family_app/providers/recipe/step_provider.dart';
import 'package:my_family_app/screens/recipe/add_recipe_screen.dart';
import 'package:my_family_app/screens/recipe/details_recipe_screen.dart';
import 'package:my_family_app/services/recipe_service.dart';
import 'package:my_family_app/services/user_service.dart';
import 'package:my_family_app/utils/constants.dart';
import 'package:my_family_app/widgets/main_app_bar.dart';
import 'package:my_family_app/widgets/main_drawer.dart';

class RecipesScreen extends ConsumerStatefulWidget {
  const RecipesScreen({super.key, this.selectedTabIndex});

  final int? selectedTabIndex;

  @override
  ConsumerState<RecipesScreen> createState() => _RecipesScreenState();
}

class _RecipesScreenState extends ConsumerState<RecipesScreen>
    with SingleTickerProviderStateMixin {
  late final TabController nestedTabBarctrl;

  final List<MyUser> usersList = myUsersList;

  @override
  void initState() {
    nestedTabBarctrl =
        TabController(length: (myUsersList.length + 1), vsync: this);

    if (widget.selectedTabIndex != null) {
      nestedTabBarctrl.index = widget.selectedTabIndex!;
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final recipesList = ref.watch(recipeStreamProvider).value;

    return Scaffold(
      extendBody: true,
      appBar: const MainAppBar(
        mainTitle: appTitle,
        backgroundColor: AppBarColors.recipe,
      ),
      drawer: const MainDrawer(),
      body: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          title: const Text(
            'Ricette',
            style: TextStyle(
              color: Colors.lightBlue,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          bottom: TabBar(
            labelColor: Colors.purple,
            indicatorSize: TabBarIndicatorSize.tab,
            indicatorColor: Colors.purple,
            unselectedLabelColor: Colors.blue[200],
            onTap: (value) {
              setState(() {
                nestedTabBarctrl.animateTo(value);
              });
            },
            controller: nestedTabBarctrl,
            tabs: [
              const Tab(
                child: Text(
                  'Tutte',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ),
              ...usersList
                  .map(
                    (myUser) => Tab(
                      child: Text(
                        myUser.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  )
                  .toList()
              // Tab(
              //   child: Text(
              //     'Muu',
              //     style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              //   ),
              // ),
              // Tab(
              //   child: Text(
              //     'Mek',
              //     style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              //   ),
              // ),
            ],
          ),
        ),
        body: recipesList == null || recipesList.isEmpty
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : TabBarView(
                controller: nestedTabBarctrl,
                physics: const BouncingScrollPhysics(),
                children: [
                  RecipesListTab(
                    recipesList: recipesList,
                    selectedTab: nestedTabBarctrl.index,
                  ),
                  ...usersList
                      .map(
                        (myUser) => RecipesListTab(
                          recipesList: recipesList
                              .where((recipeData) =>
                                  recipeData.recipe.author == myUser.id)
                              .toList(),
                          selectedTab: nestedTabBarctrl.index,
                        ),
                      )
                      .toList()
                  // RecipesListTab(
                  //   // TODO
                  //   selectedAuthor: 'Muu',
                  //   recipesList: recipesList.where((element) {
                  //     return element.recipe.author ==
                  //         FireBaseRealTimeDatabase.usersList
                  //             .firstWhere((element) => element.name == 'Muu')
                  //             .id;
                  //   }).toList(),
                  //   selectedTab: nestedTabBarctrl.index,
                  // ),
                  // RecipesListTab(
                  //   selectedAuthor: 'Mek',
                  //   recipesList: recipesList,
                  //   selectedTab: nestedTabBarctrl.index,
                  // ),
                ],
              ),
        floatingActionButtonLocation: FloatingActionButtonLocation.miniEndFloat,
        floatingActionButton: FloatingActionButton(
          heroTag: 'add_recipe',
          onPressed: () {
            ref.read(ingredientListProvider.notifier).drainList();
            ref.read(stepListProvider.notifier).drainList();
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const AddRecipeScreen(
                  updateMode: false,
                ),
              ),
            );
          },
          shape: const CircleBorder(),
          backgroundColor: Colors.lightBlueAccent,
          elevation: 12,
          child: const Icon(
            Icons.add,
            color: Colors.white,
            size: 50,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    nestedTabBarctrl.dispose();

    super.dispose();
  }
}

class RecipesListTab extends StatefulWidget {
  const RecipesListTab({
    super.key,
    this.selectedAuthor = 'Tutte',
    required this.recipesList,
    required this.selectedTab,
  });

  final String selectedAuthor;
  final List<RecipeData> recipesList;
  final int selectedTab;

  @override
  State<RecipesListTab> createState() => _RecipesListTabState();
}

class _RecipesListTabState extends State<RecipesListTab> {
  int selectedIndex = -1;
  late String currentUserUid;

  void changeSelectedIndex(int newIndex) {
    setState(() {
      if (selectedIndex == newIndex) {
        selectedIndex = newIndex;
      } else {
        selectedIndex = -1;
      }
    });
  }

  bool isShowedMenu(int widgetId) {
    return widgetId == selectedIndex;
  }

  void loadCurrentUserId() {
    User? currentUser = FireAuth.getUser();
    currentUserUid = currentUser!.uid;
  }

  @override
  void initState() {
    loadCurrentUserId();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: widget.recipesList.length + 1,
      itemBuilder: (BuildContext context, int index) {
        if (index <= widget.recipesList.length - 1) {
          final recipeData = widget.recipesList[index];

          return RecipeItemWidget(
            recipeData: recipeData,
            mustShow: isShowedMenu(index),
            onTapToggle: () {
              if (mounted) {
                setState(() {
                  if (selectedIndex == index) {
                    selectedIndex = -1;
                  } else {
                    selectedIndex = index;
                  }
                });
              }
            },
            userIsAuthor: recipeData.recipe.author == currentUserUid,
          );
        } else {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Image.asset('assets/icons8-kawaii-bread-96.png', height: 40),
                Image.asset('assets/icons8-kawaii-croissant-96.png',
                    height: 40),
                Image.asset('assets/icons8-kawaii-french-fries-96.png',
                    height: 40),
                Image.asset('assets/icons8-kawaii-noodle-96.png', height: 40),
                Image.asset('assets/icons8-kawaii-pizza-96.png', height: 40),
                Image.asset('assets/icons8-kawaii-steak-96.png', height: 40),
                Image.asset('assets/icons8-kawaii-sushi-96.png', height: 40),
              ],
            ),
          );
        }
      },
    );
  }
}

class RecipeItemWidget extends StatefulWidget {
  const RecipeItemWidget({
    super.key,
    required this.recipeData,
    required this.mustShow,
    required this.onTapToggle,
    required this.userIsAuthor,
  });

  final RecipeData recipeData;
  final bool mustShow;
  final VoidCallback onTapToggle;
  final bool userIsAuthor;

  @override
  State<RecipeItemWidget> createState() => _RecipeItemWidgetState();
}

class _RecipeItemWidgetState extends State<RecipeItemWidget> {
  late String authorName;

  @override
  void initState() {
    getAuthorName();
    super.initState();
  }

  getAuthorName() {
    setState(() {
      authorName = widget.recipeData.recipe.getAuthorNameFromId();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      color: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(20),
        ),
        side: BorderSide(
          width: 1,
          color: Colors.lightBlueAccent,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            InkWell(
              onTap: () => widget.onTapToggle(),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.recipeData.recipe.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                    overflow: TextOverflow.fade,
                  ),
                  RichText(
                    text: TextSpan(
                      text: authorName,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                      ),
                      children: [
                        WidgetSpan(
                          child: Padding(
                            padding: const EdgeInsets.only(
                              left: 8,
                            ),
                            child: Icon(
                              widget.mustShow
                                  ? Icons.keyboard_arrow_up_rounded
                                  : Icons.keyboard_arrow_down_rounded,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            widget.mustShow ? const Divider() : const SizedBox(),
            AnimatedSize(
              duration: const Duration(milliseconds: 1000),
              curve: Curves.easeInOutCubicEmphasized,
              child: Row(
                children: [
                  SizedBox(
                    height: widget.mustShow ? 70 : 0,
                    child: _ActionButtons(recipeData: widget.recipeData),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButtons extends StatelessWidget {
  const _ActionButtons({
    required this.recipeData,
  });

  final RecipeData recipeData;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: _getAuthorizedWidget(),
      ),
    );
  }

  List<Widget> _getAuthorizedWidget() {
    if (recipeData.recipe.author == FirebaseAuth.instance.currentUser!.uid) {
      return [
        _DetailsButton(recipeData: recipeData),
        _UpdateButton(
          recipeData: recipeData,
        ),
        _DeleteButton(recipeDataKey: recipeData.key),
      ];
    } else {
      return [
        _DetailsButton(recipeData: recipeData),
      ];
    }
  }
}

class _DetailsButton extends StatelessWidget {
  const _DetailsButton({
    required this.recipeData,
  });

  final RecipeData recipeData;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Color(0xFF0D47A1),
        boxShadow: [BoxShadow(blurRadius: 2, offset: Offset(-1, 1))],
      ),
      child: IconButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => DetailsRecipScreen(
                recipeDataKey: recipeData.key,
              ),
            ),
          );
        },
        icon: const Icon(Icons.open_in_full_rounded),
        color: Colors.white,
      ),
    );
  }
}

class _UpdateButton extends ConsumerWidget {
  const _UpdateButton({
    required this.recipeData,
  });

  final RecipeData recipeData;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      height: 40,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Color(0xFF1B5E20),
        boxShadow: [BoxShadow(blurRadius: 2, offset: Offset(-1, 1))],
      ),
      child: IconButton(
        onPressed: () {
          ref
              .read(ingredientListProvider.notifier)
              .addAllIngredient(recipeData.recipe.ingredients);
          ref
              .read(stepListProvider.notifier)
              .addAllStep(recipeData.recipe.steps);

          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => AddRecipeScreen(
                updateMode: true,
                recipeDataToUpdate: recipeData,
              ),
            ),
          );
        },
        icon: const Icon(Icons.mode),
        color: Colors.white,
      ),
    );
  }
}

class _DeleteButton extends StatelessWidget {
  const _DeleteButton({
    required this.recipeDataKey,
  });

  final String recipeDataKey;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      height: 40,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Color(0xFFB71C1C),
        boxShadow: [BoxShadow(blurRadius: 2, offset: Offset(-1, 1))],
      ),
      child: IconButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text('Elimina la ricetta'),
                content: const Text('Vuoi davvero eliminare la ricetta?'),
                actions: [
                  TextButton(
                    onPressed: () async {
                      var callStatus = await deleteRecipe(key: recipeDataKey);
                      if (context.mounted) {
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
        },
        icon: const Icon(Icons.delete_outline),
        color: Colors.white,
      ),
    );
  }
}
