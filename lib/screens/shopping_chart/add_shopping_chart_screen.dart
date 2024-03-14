import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_family_app/constants/app_constants.dart';
import 'package:my_family_app/models/shopping_chart.dart';
import 'package:my_family_app/providers/shopping_chart/article_shopping_chart_provider.dart';
import 'package:my_family_app/screens/shopping_chart/shopping_chart_screen.dart';
import 'package:my_family_app/services/shopping_chart_service.dart';
import 'package:my_family_app/utils/constants.dart';
import 'package:my_family_app/widgets/main_app_bar.dart';

class AddShoppingChartScreen extends ConsumerStatefulWidget {
  const AddShoppingChartScreen(
      {Key? key, required this.updateMode, this.shoppingChartData})
      : super(key: key);

  final bool updateMode;
  final ShoppingChartData? shoppingChartData;

  @override
  ConsumerState<AddShoppingChartScreen> createState() =>
      _AddShoppingChartScreenState();
}

class _AddShoppingChartScreenState
    extends ConsumerState<AddShoppingChartScreen> {
  final TextEditingController _storeTextController = TextEditingController();

  final TextEditingController _nameTextController = TextEditingController();
  final TextEditingController _quantityTextController = TextEditingController();
  final TextEditingController _noteTextController = TextEditingController();
  bool updateArticleMode = false;
  int selectedIndexOfArticle = -1;
  bool isInSaleInputvalue = false;
  bool isEnabledArticleButton = false;

  final FocusNode _articleNameInputFocus = FocusNode();

  late ShoppingChartData shoppingChartData;

  @override
  void initState() {
    super.initState();

    if (widget.updateMode && widget.shoppingChartData != null) {
      shoppingChartData = widget.shoppingChartData!;
      ShoppingChart shoppingChart = shoppingChartData.shoppingChart;

      _storeTextController.text = shoppingChart.store;
    }
  }

  void resetArticleFields() {
    _nameTextController.text = '';
    _quantityTextController.text = '';
    _noteTextController.text = '';
    isInSaleInputvalue = false;
    isEnabledArticleButton = false;

    resetUpdateArticleMode();
  }

  void resetUpdateArticleMode() {
    updateArticleMode = false;
    toggleArticleButton(false);
  }

  void toggleArticleButton(value) {
    setState(() {
      isEnabledArticleButton = value;
    });
  }

  void onRequestRefactoringArticle(Article article, int indexToUpdate) {
    _nameTextController.text = article.name;
    _quantityTextController.text = article.quantity;
    _noteTextController.text = article.note;
    updateArticleMode = true;
    selectedIndexOfArticle = indexToUpdate;
    isInSaleInputvalue = article.isInSale;

    FocusScope.of(context).requestFocus(_articleNameInputFocus);
    setState(() {});
  }

  void resetArticleUpdateMode() {
    updateArticleMode = false;
    setState(() {});
  }

  void changeIsInSale(bool value) {
    setState(() {
      isInSaleInputvalue = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Article> articlesList = ref.watch(articleListProvider);

    return Scaffold(
      extendBody: true,
      appBar: const MainAppBar(
        mainTitle: appTitle,
        backgroundColor: AppBarColors.shoppingChart,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/peeeeecora2.png',
                color: Colors.deepPurple,
              ),
              const SizedBox(
                height: 12,
              ),
              Text(
                widget.updateMode ? 'Modifica una spesa' : 'Aggiungi una spesa',
                style: Theme.of(context).textTheme.headlineLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(
                height: 24,
              ),
              Form(
                child: Column(
                  children: [
                    TextFormField(
                      controller: _storeTextController,
                      decoration: const InputDecoration(
                        filled: true,
                        fillColor: Color(0xFFE1F5FE),
                        hintText: 'Negozio',
                        labelText: 'Negozio',
                      ),
                    ),
                  ],
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
                    'Articoli',
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
                child: articlesList.isEmpty
                    ? const Row(
                        children: [
                          Spacer(),
                          Text('Nessun articolo aggiunto'),
                          Spacer(),
                        ],
                      )
                    : ListView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: articlesList.length,
                        itemBuilder: (_, index) {
                          Article article = articlesList[index];

                          if (index == articlesList.length - 1) {
                            return Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ArticleListItem(
                                    article: article,
                                    requestRefactorArticle:
                                        onRequestRefactoringArticle,
                                    indexOfArticle: index,
                                    resetArticleFields: resetArticleFields),
                              ],
                            );
                          }
                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ArticleListItem(
                                  article: article,
                                  requestRefactorArticle:
                                      onRequestRefactoringArticle,
                                  indexOfArticle: index,
                                  resetArticleFields: resetArticleFields),
                              const Divider(
                                thickness: 1,
                                color: Colors.lightBlueAccent,
                              )
                            ],
                          );
                        },
                      ),
              ),
              const SizedBox(
                height: 32,
              ),
              ArticlesInput(
                nameTextController: _nameTextController,
                quantityTextController: _quantityTextController,
                noteTextController: _noteTextController,
                articleNameInputFocus: _articleNameInputFocus,
                updateMode: updateArticleMode,
                indexToUpdate: selectedIndexOfArticle,
                isInSale: isInSaleInputvalue,
                resetArticleFields: resetArticleFields,
                changeIsInSale: changeIsInSale,
                isEnabledButton: isEnabledArticleButton,
                toggleButton: toggleArticleButton,
              ),
              const SizedBox(
                height: 12,
              ),
              Transform.flip(
                flipX: true,
                child: Image.asset(
                  'assets/peeeeecora2.png',
                  color: Colors.deepPurple,
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'add_shopping_chart',
        elevation: 12,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(36),
        ),
        backgroundColor: Colors.blue,
        onPressed: () async {
          var store = _storeTextController.text.trim();

          if (articlesList.isEmpty) {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Warning'),
                content: RichText(
                  text: const TextSpan(
                    style: TextStyle(color: Colors.black, height: 1.5),
                    children: [
                      TextSpan(
                        text: 'Non hai inserito nessun articolo!!! ',
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
            ShoppingChart newShoppingchart = ShoppingChart(
              store: store,
              articles: articlesList,
            );

            DatabaseCallStatus callStatus;

            if (widget.updateMode) {
              ShoppingChartData updatedShoppingChartData = ShoppingChartData(
                key: shoppingChartData.key,
                shoppingChart: newShoppingchart,
              );
              callStatus = await updateShoppingChart(
                newShoppingChartData: updatedShoppingChartData,
              );
            } else {
              callStatus =
                  await createShoppingChart(newShoppingChart: newShoppingchart);
            }
            ref.read(articleListProvider.notifier).drainList();
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
                    builder: (context) => const ShoppingChartScreen(),
                  ),
                  (Route<dynamic> route) => false,
                );
              }
            }
          }
        },
        label: const Text(
          'Salva',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _storeTextController.dispose();
    _nameTextController.dispose();
    _quantityTextController.dispose();
    _noteTextController.dispose();
    _articleNameInputFocus.dispose();

    super.dispose();
  }
}

class ArticleListItem extends ConsumerWidget {
  const ArticleListItem({
    super.key,
    required this.article,
    required this.requestRefactorArticle,
    required this.indexOfArticle,
    required this.resetArticleFields,
  });

  final Article article;
  final void Function(Article article, int indexToUpdate)
      requestRefactorArticle;
  final int indexOfArticle;
  final void Function() resetArticleFields;

  Widget getArticleTitle() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Expanded(
          child: Text(
            article.name,
            softWrap: true,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget getArticleBody() {
    if (article.note == '') {
      if (article.quantity == '') {
        return ListTile(
          title: getArticleTitle(),
          leading: article.getIsInSaleIcon(color: Colors.black),
        );
      } else {
        return ListTile(
          title: getArticleTitle(),
          leading: article.getIsInSaleIcon(color: Colors.black),
          subtitle: Text(article.quantity),
        );
      }
    } else {
      if (article.quantity == '') {
        return ExpansionTile(
          shape: Border.all(color: Colors.transparent),
          title: getArticleTitle(),
          expandedAlignment: Alignment.centerLeft,
          leading: article.getIsInSaleIcon(color: Colors.black),
          children: [Text(article.note)],
        );
      } else {
        return ExpansionTile(
          shape: Border.all(color: Colors.transparent),
          title: getArticleTitle(),
          expandedAlignment: Alignment.centerLeft,
          leading: article.getIsInSaleIcon(color: Colors.black),
          subtitle: Text(article.quantity),
          children: [Text(article.note)],
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: getArticleBody()),
          IconButton(
            padding: EdgeInsets.zero,
            onPressed: () => requestRefactorArticle(
              article,
              indexOfArticle,
            ),
            icon: const Icon(
              Icons.mode,
              color: Color(0xFF00796B),
            ),
            style: const ButtonStyle(
              elevation: MaterialStatePropertyAll(5),
              shadowColor: MaterialStatePropertyAll(Colors.grey),
              backgroundColor: MaterialStatePropertyAll(Colors.white),
              side: MaterialStatePropertyAll(
                BorderSide(
                  color: Colors.lightBlueAccent,
                ),
              ),
            ),
          ),
          IconButton(
            padding: EdgeInsets.zero,
            onPressed: () {
              ref
                  .read(articleListProvider.notifier)
                  .removeArticle(indexOfArticle);

              resetArticleFields();
            },
            icon: const Icon(
              Icons.delete,
              color: Color(0xFFB71C1C),
            ),
            style: const ButtonStyle(
              elevation: MaterialStatePropertyAll(5),
              shadowColor: MaterialStatePropertyAll(Colors.grey),
              backgroundColor: MaterialStatePropertyAll(Colors.white),
              side: MaterialStatePropertyAll(
                BorderSide(
                  color: Colors.lightBlueAccent,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ArticlesInput extends ConsumerStatefulWidget {
  const ArticlesInput({
    super.key,
    required this.resetArticleFields,
    required this.nameTextController,
    required this.quantityTextController,
    required this.noteTextController,
    required this.articleNameInputFocus,
    required this.updateMode,
    required this.indexToUpdate,
    required this.isInSale,
    required this.isEnabledButton,
    required this.toggleButton,
    required this.changeIsInSale,
  });

  final void Function() resetArticleFields;
  final TextEditingController nameTextController;
  final TextEditingController quantityTextController;
  final TextEditingController noteTextController;
  final FocusNode articleNameInputFocus;
  final bool updateMode;
  final int indexToUpdate;
  final bool isInSale;
  final bool isEnabledButton;
  final void Function(bool value) toggleButton;
  final void Function(bool value) changeIsInSale;

  @override
  ConsumerState<ArticlesInput> createState() => _ArticlesInputState();
}

class _ArticlesInputState extends ConsumerState<ArticlesInput> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextFormField(
          controller: widget.nameTextController,
          focusNode: widget.articleNameInputFocus,
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
            hintText: 'Nome dell\'articolo',
            fillColor: Color(0xffe1f5fe),
            labelText: 'Nome dell\'articolo',
          ),
        ),
        const SizedBox(
          height: 20,
        ),
        Row(
          children: [
            Expanded(
              flex: 2,
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
                  hintText: 'Quantità (es 100 gr, 1 pezzo, ecc.)',
                  fillColor: Color(0xffe1f5fe),
                  labelText: 'Quantità',
                ),
              ),
            ),
            const SizedBox(
              width: 12,
            ),
            Expanded(
              flex: 1,
              child: Column(
                children: [
                  const Text('In sconto'),
                  Switch(
                    thumbIcon: MaterialStateProperty.resolveWith<Icon?>(
                        (Set<MaterialState> states) {
                      return widget.isInSale
                          ? const Icon(
                              Icons.check,
                              color: Colors.white,
                              weight: 1000,
                              size: 25,
                            )
                          : const Icon(
                              Icons.close,
                              weight: 1000,
                              size: 25,
                            );
                    }),
                    activeColor: Colors.lightBlueAccent.shade700,
                    splashRadius: 50.0,
                    value: widget.isInSale,
                    onChanged: (value) {
                      widget.changeIsInSale(value);

                      if (!widget.isEnabledButton &&
                          widget.nameTextController.text != '') {
                        widget.toggleButton(true);
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(
          height: 20,
        ),
        TextFormField(
          controller: widget.noteTextController,
          onChanged: (_) {
            if (!widget.isEnabledButton &&
                widget.nameTextController.text != '') {
              widget.toggleButton(true);
            }
          },
          decoration: const InputDecoration(
            filled: true,
            hintText: 'Note',
            fillColor: Color(0xffe1f5fe),
            labelText: 'Note',
          ),
        ),
        const SizedBox(
          height: 20,
        ),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: !widget.isEnabledButton
                    ? null
                    : () {
                        FocusScope.of(context)
                            .requestFocus(widget.articleNameInputFocus);

                        if (widget.nameTextController.value.text == '') {
                          return;
                        }

                        Article newArticle = Article(
                          name: widget.nameTextController.text,
                          quantity: widget.quantityTextController.text,
                          isInSale: widget.isInSale,
                          note: widget.noteTextController.text,
                        );

                        bool response;

                        if (widget.updateMode) {
                          response = ref
                              .read(articleListProvider.notifier)
                              .update(newArticle, widget.indexToUpdate);
                        } else {
                          response = ref
                              .read(articleListProvider.notifier)
                              .addArticle(newArticle);
                        }

                        if (response == false) {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: const Text(
                                    'Attenzione. Hai già questo articolo!!!'),
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

                        widget.resetArticleFields();
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
                onPressed: () {
                  widget.resetArticleFields();
                },
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
