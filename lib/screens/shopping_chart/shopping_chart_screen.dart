import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_family_app/constants/app_constants.dart';
import 'package:my_family_app/extensions/date_time_x.dart';
import 'package:my_family_app/models/shopping_chart.dart';
import 'package:my_family_app/providers/shopping_chart/article_shopping_chart_provider.dart';
import 'package:my_family_app/providers/shopping_chart/shopping_chart_stream_provider.dart';
import 'package:my_family_app/screens/shopping_chart/add_shopping_chart_screen.dart';
import 'package:my_family_app/screens/shopping_chart/details_shopping_chart_screen.dart';
import 'package:my_family_app/services/shopping_chart_service.dart';
import 'package:my_family_app/utils/constants.dart';
import 'package:my_family_app/widgets/main_app_bar.dart';
import 'package:my_family_app/widgets/main_drawer.dart';

class ShoppingChartScreen extends ConsumerStatefulWidget {
  const ShoppingChartScreen({super.key});

  @override
  ConsumerState<ShoppingChartScreen> createState() =>
      _ShoppingChartScreenState();
}

class _ShoppingChartScreenState extends ConsumerState<ShoppingChartScreen>
    with SingleTickerProviderStateMixin {
  int selectedIndex = -1;

  int previousLength = 0;

  @override
  Widget build(BuildContext context) {
    final shoppingList = ref.watch(shoppingChartStreamProvider).value;

    if (shoppingList != null) {
      if (shoppingList.length < previousLength) {
        selectedIndex = -1;
      }
      previousLength = shoppingList.length;
    }

    return Scaffold(
      extendBody: true,
      appBar: const MainAppBar(
        mainTitle: appTitle,
        backgroundColor: AppBarColors.shoppingChart,
      ),
      drawer: const MainDrawer(),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          children: [
            const Align(
              alignment: Alignment.center,
              child: Text(
                'Liste della spesa',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Color.fromRGBO(3, 155, 229, 1),
                ),
              ),
            ),
            const SizedBox(
              height: 12,
            ),
            shoppingList != null
                ? ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: shoppingList.length + 1,
                    itemBuilder: (context, index) {
                      if (index <= shoppingList.length - 1) {
                        final shoppingChartData = shoppingList[index];

                        return ShoppingItemWidget(
                          shoppingChartData: shoppingChartData,
                          mustShow: index == selectedIndex,
                          onTapToggle: () {
                            setState(() {
                              if (selectedIndex == index) {
                                selectedIndex = -1;
                              } else {
                                selectedIndex = index;
                              }
                            });
                          },
                        );
                      } else {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Image.asset(
                            'assets/peeeeecora2.png',
                            color: Colors.deepPurple,
                          ),
                        );
                      }
                    },
                  )
                : const SizedBox(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'add_shopping_chart',
        onPressed: () {
          ref.read(articleListProvider.notifier).drainList();

          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const AddShoppingChartScreen(
                updateMode: false,
              ),
            ),
          );
        },
        shape: const CircleBorder(),
        backgroundColor: Colors.blue,
        elevation: 12,
        child: const Icon(
          Icons.add,
          color: Colors.white,
          size: 50,
        ),
      ),
    );
  }
}

class ShoppingItemWidget extends StatelessWidget {
  const ShoppingItemWidget({
    super.key,
    required this.shoppingChartData,
    required this.mustShow,
    required this.onTapToggle,
  });

  final ShoppingChartData shoppingChartData;
  final bool mustShow;
  final VoidCallback onTapToggle;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      shape: const ContinuousRectangleBorder(),
      elevation: 8,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            InkWell(
              onTap: () => onTapToggle(),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    shoppingChartData.shoppingChart.store,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                    softWrap: true,
                    overflow: TextOverflow.fade,
                  ),
                  RichText(
                    text: TextSpan(
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                      ),
                      text: shoppingChartData.shoppingChart.creationDate
                          .formatToItalian(),
                      children: [
                        WidgetSpan(
                            child: Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: Icon(
                            mustShow
                                ? Icons.keyboard_arrow_up_rounded
                                : Icons.keyboard_arrow_down_rounded,
                          ),
                        )),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            mustShow ? const Divider() : const SizedBox(),
            AnimatedSize(
              duration: const Duration(milliseconds: 1000),
              curve: Curves.easeInOutCubicEmphasized,
              child: Row(
                children: [
                  SizedBox(
                    height: mustShow ? 70 : 0,
                    child: Visibility(
                      visible: mustShow,
                      child:
                          _ActionButtons(shoppingChartData: shoppingChartData),
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class _ActionButtons extends StatelessWidget {
  const _ActionButtons({
    required this.shoppingChartData,
  });

  final ShoppingChartData shoppingChartData;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          _DetailsButton(shoppingChartData: shoppingChartData),
          _UpdateButton(
            shoppingChartData: shoppingChartData,
          ),
          _DeleteButton(shoppingChartDataKey: shoppingChartData.key),
        ],
      ),
    );
  }
}

class _DetailsButton extends StatelessWidget {
  const _DetailsButton({
    required this.shoppingChartData,
  });

  final ShoppingChartData shoppingChartData;

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
              builder: (context) => DetailsShoppingChartScreen(
                shoppingChartDataKey: shoppingChartData.key,
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
    required this.shoppingChartData,
  });

  final ShoppingChartData shoppingChartData;

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
              .read(articleListProvider.notifier)
              .addAllArticle(shoppingChartData.shoppingChart.articles);

          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => AddShoppingChartScreen(
                updateMode: true,
                shoppingChartData: shoppingChartData,
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
    required this.shoppingChartDataKey,
  });

  final String shoppingChartDataKey;

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
                title: const Text('Elimina lista della spesa'),
                content:
                    const Text('Vuoi davvero eliminare la lista della spesa?'),
                actions: [
                  TextButton(
                    onPressed: () async {
                      var callStatus =
                          await deleteShoppingChart(key: shoppingChartDataKey);
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
