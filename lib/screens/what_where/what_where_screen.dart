import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_family_app/constants/app_constants.dart';
import 'package:my_family_app/extensions/date_time_x.dart';
import 'package:my_family_app/models/what_where.dart';
import 'package:my_family_app/providers/what_where/what_where_stream_provider.dart';
import 'package:my_family_app/screens/what_where/add_what_where_screen.dart';
import 'package:my_family_app/services/what_where_service.dart';
import 'package:my_family_app/widgets/main_app_bar.dart';
import 'package:my_family_app/widgets/main_drawer.dart';

class WhatWhereScreen extends ConsumerStatefulWidget {
  const WhatWhereScreen({super.key});

  @override
  ConsumerState<WhatWhereScreen> createState() => _WhatWhereScreenState();
}

class _WhatWhereScreenState extends ConsumerState<WhatWhereScreen> {
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
    final whatWhereList = ref.watch(whatWhereStreamProvider).value;

    return Scaffold(extendBody: true,
      appBar: const MainAppBar(
        mainTitle: appTitle,
        backgroundColor: AppBarColors.whatWhere,
      ),
      drawer: const MainDrawer(),
      body: CustomScrollView(
        slivers: [
          SliverFillRemaining(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Align(
                    alignment: Alignment.center,
                    child: Text(
                      'Cosa Dove',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 12,
                  ),
                  if (whatWhereList == null)
                    const Center(
                      child: CircularProgressIndicator(),
                    )
                  else if (whatWhereList.isEmpty)
                    Expanded(
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
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: whatWhereList.length + 1,
                        itemBuilder: (context, index) {
                          if (index <= whatWhereList.length - 1) {
                            final whatWhereData = whatWhereList[index];
                            return WhatWhereItemWidget(
                              whatWhereData: whatWhereData,
                            );
                          } else {
                            return Padding(
                              padding: const EdgeInsets.fromLTRB(0, 12, 0, 8),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  Image.asset('assets/vestito.png', height: 60),
                                  Image.asset('assets/attrezzi.png', height: 50),
                                  Image.asset('assets/pacco.png', height: 60),
                                  Image.asset('assets/peluche.png', height: 50),
                                  Image.asset('assets/libri.png', height: 60),
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
        heroTag: 'add_what_where',
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => const AddWhatWhereScreen(
              updateMode: false,
            ),
          ));
        },
        shape: const CircleBorder(),
        backgroundColor: Colors.orange,
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

class WhatWhereItemWidget extends StatelessWidget {
  const WhatWhereItemWidget({
    super.key,
    required this.whatWhereData,
  });

  final WhatWhereData whatWhereData;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => AddWhatWhereScreen(
          updateMode: true,
          whatWhereDataToUpdate: whatWhereData,
        ),
      )),
      child: Dismissible(
        key: Key(whatWhereData.key),
        direction: DismissDirection.startToEnd,
        confirmDismiss: (direction) async {
          return await showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text('Vuoi cancellare l\'elemento?'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      'No, lascialo',
                      style: TextStyle(
                        color: Colors.orange.shade700,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () async {
                      if (context.mounted) {
                        Navigator.of(context).pop();
                      }
                      await deleteWhatWhere(key: whatWhereData.key);
                    },
                    child: Text(
                      'Sì, elimina',
                      style: TextStyle(
                        color: Colors.orange.shade700,
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
        background: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
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
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        whatWhereData.whatWhere.what,
                        softWrap: true,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        whatWhereData.whatWhere.where,
                      ),
                    ],
                  ),
                ),
                Text(
                  whatWhereData.whatWhere.when.toLocal().formatToItalian(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
