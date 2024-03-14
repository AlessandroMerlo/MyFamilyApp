import 'dart:async';
import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_family_app/constants/app_constants.dart';
import 'package:my_family_app/models/recipe.dart';
import 'package:my_family_app/providers/recipe/recipe_stream_provider.dart';
import 'package:my_family_app/widgets/main_app_bar.dart';
import 'package:url_launcher/url_launcher.dart';

class DetailsRecipScreen extends StatefulWidget {
  const DetailsRecipScreen({
    super.key,
    required this.recipeDataKey,
  });

  final String recipeDataKey;

  @override
  State<DetailsRecipScreen> createState() => _DetailsRecipScreenState();
}

class _DetailsRecipScreenState extends State<DetailsRecipScreen> {
  bool isIngredientsExpanded = false;
  bool isStepExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      appBar: const MainAppBar(
        mainTitle: appTitle,
        backgroundColor: AppBarColors.recipe,
      ),
      body: Consumer(
        builder: (context, ref, child) {
          final recipeData = ref
              .watch(recipeStreamProvider)
              .value!
              .firstWhereOrNull(
                  (element) => element.key == widget.recipeDataKey);

          if (recipeData != null) {
            final recipe = recipeData.recipe;

            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Center(
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Image.asset('assets/icons8-kawaii-bread-96.png',
                              height: 40),
                          Image.asset('assets/icons8-kawaii-croissant-96.png',
                              height: 40),
                          Image.asset(
                              'assets/icons8-kawaii-french-fries-96.png',
                              height: 40),
                          Image.asset('assets/icons8-kawaii-noodle-96.png',
                              height: 40),
                          Image.asset('assets/icons8-kawaii-pizza-96.png',
                              height: 40),
                          Image.asset('assets/icons8-kawaii-steak-96.png',
                              height: 40),
                          Image.asset('assets/icons8-kawaii-sushi-96.png',
                              height: 40),
                        ],
                      ),
                      const SizedBox(
                        height: 32,
                      ),
                      Text(
                        recipe.title,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontFamily: 'Marck Script',
                            fontSize: 50,
                            fontWeight: FontWeight.bold,
                            wordSpacing: -10),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Container(
                        padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              blurRadius: 2,
                              offset: const Offset(-4, 4),
                              color: Colors.grey.withOpacity(0.7),
                            ),
                          ],
                          border: Border.all(
                            color: const Color.fromARGB(255, 64, 196, 255),
                          ),
                          borderRadius: const BorderRadius.all(
                            Radius.circular(30),
                          ),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Image.asset(
                                  'assets/icons8-cappello-dello-chef-64.png',
                                  width: 40,
                                ),
                                const SizedBox(
                                  width: 8,
                                ),
                                Text(
                                  recipe.getItalianWord(),
                                  style: const TextStyle(),
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 8,
                            ),
                            Row(
                              children: [
                                const Icon(
                                  Icons.timer_sharp,
                                  color: Colors.lightBlueAccent,
                                  size: 40,
                                ),
                                const SizedBox(
                                  width: 8,
                                ),
                                Text('${recipe.preparationTime} minuti')
                              ],
                            ),
                            const SizedBox(
                              height: 4,
                            ),
                            Row(
                              children: [
                                const Icon(
                                  Icons.people_alt_outlined,
                                  color: Colors.lightBlueAccent,
                                  size: 40,
                                ),
                                const SizedBox(width: 8),
                                Text('Per ${recipe.servings} persone')
                              ],
                            ),
                            Row(
                              children: [
                                const Icon(
                                  Icons.link,
                                  color: Colors.lightBlueAccent,
                                  size: 40,
                                ),
                                const SizedBox(width: 8),
                                recipe.externalLink != ''
                                    ? RichText(
                                        text: TextSpan(
                                          style: const TextStyle(
                                            color: Colors.blue,
                                            decoration:
                                                TextDecoration.underline,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                          text:
                                              'Apri il link della ricetta nel browser',
                                          recognizer: TapGestureRecognizer()
                                            ..onTap = () async {
                                              var uri = Uri.tryParse(
                                                  '${recipe.externalLink}?a=${Random().nextDouble()}');
                                              if (uri != null &&
                                                  await canLaunchUrl(uri)) {
                                                await launchUrl(uri);
                                              }
                                            },
                                        ),
                                      )
                                    : const Text('Nessun link'),
                              ],
                            )
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 32,
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 32),
                              child: Container(
                                decoration: const BoxDecoration(
                                  boxShadow: [
                                    BoxShadow(
                                      blurRadius: 2,
                                      offset: Offset(-4, 4),
                                      color: Colors.grey,
                                    ),
                                  ],
                                ),
                                child: const Divider(
                                  height: 3,
                                  thickness: 3,
                                  color: Colors.lightBlueAccent,
                                ),
                              ),
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8),
                            child: Text(
                              'Ingredienti',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontFamily: 'Marck Script',
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                  shadows: [
                                    BoxShadow(
                                      blurRadius: 2,
                                      offset: Offset(-2, 2),
                                      color: Colors.grey,
                                    ),
                                  ]),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 32),
                              child: Container(
                                decoration: const BoxDecoration(
                                  boxShadow: [
                                    BoxShadow(
                                      blurRadius: 2,
                                      offset: Offset(-4, 4),
                                      color: Colors.grey,
                                    ),
                                  ],
                                ),
                                child: const Divider(
                                  height: 3,
                                  thickness: 3,
                                  color: Colors.lightBlueAccent,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              blurRadius: 2,
                              offset: const Offset(-4, 4),
                              color: Colors.grey.withOpacity(0.7),
                            ),
                          ],
                          border: Border.all(
                            color: const Color.fromARGB(255, 64, 196, 255),
                          ),
                          borderRadius: const BorderRadius.all(
                            Radius.circular(30),
                          ),
                        ),
                        child: AnimatedCrossFade(
                          duration: const Duration(milliseconds: 300),
                          firstChild: InkWell(
                            splashFactory: NoSplash.splashFactory,
                            onTap: () => setState(() {
                              isIngredientsExpanded = false;
                            }),
                            child: Padding(
                              padding:
                                  const EdgeInsets.fromLTRB(16, 20, 16, 20),
                              child: ListView.builder(
                                scrollDirection: Axis.vertical,
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: recipe.ingredients.length,
                                itemBuilder: (context, index) {
                                  Ingredient ingredient =
                                      recipe.ingredients[index];

                                  return Container(
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 4),
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Icons.double_arrow_rounded,
                                          size: 20,
                                          color: Colors.lightBlueAccent,
                                        ),
                                        const SizedBox(
                                          width: 8,
                                        ),
                                        Expanded(
                                          child: RichText(
                                            overflow: TextOverflow.visible,
                                            text: TextSpan(
                                              style: const TextStyle(
                                                color: Colors.black,
                                                fontSize: 18,
                                              ),
                                              children: [
                                                TextSpan(
                                                  text: ingredient.name,
                                                ),
                                                const WidgetSpan(
                                                  child: SizedBox(
                                                    width: 12,
                                                  ),
                                                ),
                                                TextSpan(
                                                  text: ingredient.quantity
                                                      .toString(),
                                                ),
                                                const WidgetSpan(
                                                  child: SizedBox(
                                                    width: 6,
                                                  ),
                                                ),
                                                TextSpan(
                                                  text: ingredient
                                                      .unitMeasurement,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          secondChild: InkWell(
                            splashFactory: NoSplash.splashFactory,
                            onTap: () => setState(() {
                              isIngredientsExpanded = true;
                            }),
                            child: const Padding(
                              padding: EdgeInsets.fromLTRB(16, 20, 16, 20),
                              child: Align(
                                alignment: Alignment.center,
                                child: Text(
                                  'Espandi',
                                ),
                              ),
                            ),
                          ),
                          crossFadeState: isIngredientsExpanded
                              ? CrossFadeState.showFirst
                              : CrossFadeState.showSecond,
                        ),
                      ),
                      const SizedBox(
                        height: 32,
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 32),
                              child: Container(
                                decoration: const BoxDecoration(
                                  boxShadow: [
                                    BoxShadow(
                                      blurRadius: 2,
                                      offset: Offset(-4, 4),
                                      color: Colors.grey,
                                    ),
                                  ],
                                ),
                                child: const Divider(
                                  height: 3,
                                  thickness: 3,
                                  color: Colors.lightBlueAccent,
                                ),
                              ),
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8),
                            child: Text(
                              'Procedimento',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontFamily: 'Marck Script',
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                  shadows: [
                                    BoxShadow(
                                      blurRadius: 2,
                                      offset: Offset(-2, 2),
                                      color: Colors.grey,
                                    ),
                                  ]),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 32),
                              child: Container(
                                decoration: const BoxDecoration(
                                  boxShadow: [
                                    BoxShadow(
                                      blurRadius: 2,
                                      offset: Offset(-4, 4),
                                      color: Colors.grey,
                                    ),
                                  ],
                                ),
                                child: const Divider(
                                  height: 3,
                                  thickness: 3,
                                  color: Colors.lightBlueAccent,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      AnimatedCrossFade(
                        duration: const Duration(milliseconds: 300),
                        firstChild: InkWell(
                          splashFactory: NoSplash.splashFactory,
                          onTap: () => setState(() {
                            isStepExpanded = false;
                          }),
                          child: ListView.builder(
                            scrollDirection: Axis.vertical,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: recipe.steps.length,
                            itemBuilder: (context, index) {
                              String step = recipe.steps[index];
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                  horizontal: 4,
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
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
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                        secondChild: InkWell(
                          splashFactory: NoSplash.splashFactory,
                          onTap: () => setState(() {
                            isStepExpanded = true;
                          }),
                          child: const Align(
                            alignment: Alignment.center,
                            child: Text(
                              'Espandi',
                            ),
                          ),
                        ),
                        crossFadeState: isStepExpanded
                            ? CrossFadeState.showFirst
                            : CrossFadeState.showSecond,
                      ),
                      const SizedBox(
                        height: 32,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Image.asset('assets/icons8-kawaii-bread-96.png',
                              height: 40),
                          Image.asset('assets/icons8-kawaii-croissant-96.png',
                              height: 40),
                          Image.asset(
                              'assets/icons8-kawaii-french-fries-96.png',
                              height: 40),
                          Image.asset('assets/icons8-kawaii-noodle-96.png',
                              height: 40),
                          Image.asset('assets/icons8-kawaii-pizza-96.png',
                              height: 40),
                          Image.asset('assets/icons8-kawaii-steak-96.png',
                              height: 40),
                          Image.asset('assets/icons8-kawaii-sushi-96.png',
                              height: 40),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          } else {
            Future.delayed(Duration.zero, () {
              const snackbar = SnackBar(
                content: Text(
                  'Qualcuno ha cancellato la ricetta',
                  textScaleFactor: 1.3,
                ),
                duration: Duration(seconds: 5),
                padding: EdgeInsets.all(24),
              );

              ScaffoldMessenger.of(context).showSnackBar(snackbar);
              // showDialog(
              //     context: context,
              //     builder: (context) => AlertDialog(
              //           title: const Text('Qualcuno ha cancellato la ricetta'),
              //           actions: [
              //             TextButton(
              //               onPressed: () => Navigator.of(context).pop(),
              //               child: const Text('Ho capito'),
              //             )
              //           ],
              //         ));
            });
            return const Center(
              child: SingleChildScrollView(
                  child: Center(child: CircularProgressIndicator())),
            );
          }
        },
      ),
    );
  }

  // @override
  // void dispose() {
  //   onRemoveNoteListener.cancel();
  //   onUpdateNoteListener.cancel();
  //   super.dispose();
  // }
}
