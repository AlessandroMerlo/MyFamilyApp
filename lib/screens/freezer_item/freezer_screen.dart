import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_family_app/constants/app_constants.dart';
import 'package:my_family_app/extensions/date_time_x.dart';
import 'package:my_family_app/providers/freezer_item/freezer_item_stream_provider.dart';
import 'package:my_family_app/screens/freezer_item/add_freezer_screen.dart';
import 'package:my_family_app/services/frerezer_item_service.dart';
import 'package:my_family_app/widgets/main_app_bar.dart';
import 'package:my_family_app/widgets/main_drawer.dart';

class FreezerScreen extends ConsumerStatefulWidget {
  const FreezerScreen({super.key});

  @override
  ConsumerState<FreezerScreen> createState() => _FreezerScreenState();
}

class _FreezerScreenState extends ConsumerState<FreezerScreen> {
  bool isFlashing = true;
  late Timer _animationTimer;
  @override
  void initState() {
    super.initState();

    _animationTimer =
        Timer.periodic(const Duration(milliseconds: 500), (timer) {
      setState(() {
        isFlashing = !isFlashing;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final freezerItemsList = ref.watch(freezerItemsStreamProvider).value;

    return Scaffold(
      extendBody: true,
      appBar: const MainAppBar(
        mainTitle: appTitle,
        backgroundColor: AppBarColors.freezer,
      ),
      drawer: const MainDrawer(),
      body: CustomScrollView(
        slivers: [
          SliverFillRemaining(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Align(
                    alignment: Alignment.center,
                    child: Text(
                      'Freezer',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.cyan,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 12,
                  ),
                  if (freezerItemsList == null)
                    const Center(
                      child: CircularProgressIndicator(),
                    )
                  else if (freezerItemsList.isEmpty)
                    Flexible(
                      child: Center(
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 500),
                          padding: const EdgeInsets.all(16),
                          decoration: ShapeDecoration(
                            color: Colors.cyanAccent,
                            shape: RoundedRectangleBorder(
                              side: BorderSide(
                                color: isFlashing
                                    ? Colors.redAccent
                                    : Colors.transparent,
                                width: 4,
                                strokeAlign: 4,
                              ),
                              borderRadius: const BorderRadius.all(
                                Radius.circular(35),
                              ),
                            ),
                          ),
                          child: const Text(
                            '🙀 Il freezer è vuoto 🙀',
                            style: TextStyle(
                                fontSize: 26, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    )
                  else
                    Expanded(
                      child: ListView.builder(
                        shrinkWrap: true,
                        physics: const BouncingScrollPhysics(),
                        itemCount: freezerItemsList.length + 1,
                        itemBuilder: (context, index) {
                          if (index <= freezerItemsList.length - 1) {
                            final freezerItemData = freezerItemsList[index];

                            bool isExpired = !freezerItemData
                                .freezerItem.expirationDate
                                .toLocal()
                                .isPastDate();

                            bool isNearToExpire = !freezerItemData
                                .freezerItem.expirationDate
                                .toLocal()
                                .isNearDate();

                            Color? color;

                            if (isExpired) {
                              color = Colors.red[700];
                            } else if (isNearToExpire) {
                              color = Colors.amber[800];
                            } else {
                              color = Colors.green[900];
                            }

                            TextStyle textStyle = TextStyle(
                              color: color,
                              fontWeight: FontWeight.bold,
                            );

                            return GestureDetector(
                              onTap: () =>
                                  Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => AddFreezerScreen(
                                  updateMode: true,
                                  freezerItemDataToUpdate: freezerItemData,
                                ),
                              )),
                              child: Dismissible(
                                key: Key(freezerItemData.key),
                                direction: DismissDirection.startToEnd,
                                confirmDismiss: (direction) async {
                                  return await showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        title: const Text(
                                            'Vuoi cancellare l\'elemento?'),
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                            child: const Text(
                                              'No, lascialo',
                                              style: TextStyle(
                                                color: Colors.cyan,
                                              ),
                                            ),
                                          ),
                                          TextButton(
                                            onPressed: () async {
                                              if (context.mounted) {
                                                Navigator.of(context).pop();
                                              }
                                              await deleteFreezerItem(
                                                  key: freezerItemData.key);
                                            },
                                            child: const Text(
                                              'Sì, elimina',
                                              style: TextStyle(
                                                color: Colors.cyan,
                                              ),
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                                background: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 24, vertical: 16),
                                  child: Align(
                                    alignment: AlignmentDirectional.centerStart,
                                    child: Icon(
                                      Icons.delete_forever,
                                      color: Colors.red.shade700,
                                      size: 40,
                                    ),
                                  ),
                                ),
                                child: Card(
                                  elevation: 8,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 16),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                freezerItemData
                                                    .freezerItem.name,
                                                softWrap: true,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              Text(
                                                freezerItemData
                                                    .freezerItem.quantity,
                                              ),
                                            ],
                                          ),
                                        ),
                                        Column(
                                          children: [
                                            Text(
                                              'New: ${freezerItemData.freezerItem.frostingDate.toLocal().formatToItalian()}',
                                            ),
                                            Text(
                                              'Exp: ${freezerItemData.freezerItem.expirationDate.toLocal().formatToItalian()}',
                                              style: textStyle,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          } else {
                            return Padding(
                              padding: const EdgeInsets.fromLTRB(0, 12, 0, 8),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Image.asset('assets/fiocco-di-neve-64.png',
                                      height: 60),
                                  Image.asset('assets/snowflakes-64.png',
                                      height: 50),
                                  Image.asset('assets/fiocco-di-neve-64.png',
                                      height: 60),
                                  Image.asset('assets/snowflakes-64.png',
                                      height: 50),
                                  Image.asset('assets/fiocco-di-neve-64.png',
                                      height: 60),
                                  Image.asset('assets/snowflakes-64.png',
                                      height: 50)
                                ],
                              ),
                            );
                          }
                        },
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.miniEndFloat,
      floatingActionButton: FloatingActionButton(
        heroTag: 'add_freezer_item',
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => const AddFreezerScreen(
              updateMode: false,
            ),
          ));
        },
        shape: const CircleBorder(),
        backgroundColor: Colors.cyan,
        elevation: 12,
        child: const Icon(
          Icons.add,
          color: Colors.white,
          size: 50,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _animationTimer.cancel();
    super.dispose();
  }
}
