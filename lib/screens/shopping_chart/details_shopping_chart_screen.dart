import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_family_app/constants/app_constants.dart';
import 'package:my_family_app/extensions/date_time_x.dart';
import 'package:my_family_app/models/shopping_chart.dart';
import 'package:my_family_app/providers/shopping_chart/shopping_chart_stream_provider.dart';
import 'package:my_family_app/widgets/main_app_bar.dart';

class DetailsShoppingChartScreen extends StatefulWidget {
  const DetailsShoppingChartScreen({
    super.key,
    required this.shoppingChartDataKey,
  });

  final String shoppingChartDataKey;

  @override
  State<DetailsShoppingChartScreen> createState() =>
      _DetailsShoppingChartScreenState();
}

class _DetailsShoppingChartScreenState
    extends State<DetailsShoppingChartScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      appBar: const MainAppBar(
        mainTitle: appTitle,
        backgroundColor: AppBarColors.shoppingChart,
      ),
      body: Consumer(
        builder: (context, ref, child) {
          final shoppingChartData = ref
              .watch(shoppingChartStreamProvider)
              .value!
              .firstWhereOrNull(
                  (element) => element.key == widget.shoppingChartDataKey);

          if (shoppingChartData != null) {
            final shoppingChart = shoppingChartData.shoppingChart;

            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/peeeeecora2.png',
                      color: Colors.deepPurple,
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Text(
                      shoppingChart.store,
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    Text(
                      shoppingChart.creationDate.formatToItalian(),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: shoppingChart.articles.length,
                      itemBuilder: (context, index) {
                        Article article = shoppingChart.articles[index];
                        if (index == shoppingChart.articles.length - 1) {
                          return Column(
                            children: [
                              getArticleListItem(article),
                            ],
                          );
                        }
                        return Column(
                          children: [
                            getArticleListItem(article),
                            const Divider(
                              color: Colors.lightBlueAccent,
                              thickness: 1,
                            )
                          ],
                        );
                      },
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Image.asset(
                      'assets/peeeeecora2.png',
                      color: Colors.deepPurple,
                    ),
                  ],
                ),
              ),
            );
          } else {
            Future.delayed(Duration.zero, () {
              const snackbar = SnackBar(
                content: Text(
                  'Qualcuno ha cancellato la spesa',
                  textScaleFactor: 1.3,
                ),
                duration: Duration(seconds: 5),
                padding: EdgeInsets.all(24),
              );

              ScaffoldMessenger.of(context).showSnackBar(snackbar);
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
}

Widget getArticleListItem(Article article) {
  if (article.note == '') {
    if (article.quantity == '') {
      return ListTile(
        title: Text(
          article.name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: article.getIsInSaleIcon(color: Colors.black),
      );
    } else {
      return ListTile(
        title: Text(
          article.name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: article.getIsInSaleIcon(color: Colors.black),
        subtitle: Text(
          article.quantity,
          style: const TextStyle(color: Colors.blue),
        ),
      );
    }
  } else {
    if (article.quantity == '') {
      return ExpansionTile(
        leading: article.getIsInSaleIcon(color: Colors.black),
        shape: Border.all(color: Colors.transparent),
        expandedAlignment: Alignment.centerLeft,
        title: Text(
          article.name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        children: [
          Text(article.note),
        ],
      );
    } else {
      return ExpansionTile(
        leading: article.getIsInSaleIcon(color: Colors.black),
        shape: Border.all(color: Colors.transparent),
        expandedAlignment: Alignment.centerLeft,
        title: Text(
          article.name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        subtitle: Text(
          article.quantity,
          style: const TextStyle(color: Colors.blue),
        ),
        children: [
          Text(article.note),
        ],
      );
    }
  }
  // }
}
