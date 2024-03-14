import 'dart:core';

import 'package:collection/collection.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:my_family_app/constants/app_constants.dart';
import 'package:my_family_app/extensions/nutrient_level_x.dart';
import 'package:my_family_app/extensions/product_packaging_x.dart';
import 'package:my_family_app/extensions/product_x.dart';
import 'package:my_family_app/screens/scanner/scanner_screen.dart';
import 'package:my_family_app/widgets/main_app_bar.dart';
import 'package:my_family_app/widgets/main_drawer.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:url_launcher/url_launcher.dart';

class ProductScreen extends StatefulWidget {
  const ProductScreen({super.key, required this.barcode});

  final String barcode;

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  late Product? result;

  Future<Product?> fetchData() async {
    ProductQueryConfiguration configuration = ProductQueryConfiguration(
      widget.barcode,
      version: ProductQueryVersion.v3,
      country: OpenFoodFactsCountry.USA,
      language: OpenFoodFactsLanguage.ENGLISH,
    );

    try {
      ProductResultV3 productResult =
          await OpenFoodAPIClient.getProductV3(configuration);

      if (productResult.status == ProductResultV3.statusSuccess) {
        return Future.value(productResult.product);
      }
    } catch (error) {
      return null;
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      appBar: const MainAppBar(
        mainTitle: appTitle,
        backgroundColor: Colors.purple,
      ),
      drawer: const MainDrawer(),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SizedBox(
            width: double.infinity,
            child: FutureBuilder<Product?>(
              future: fetchData(),
              builder:
                  (BuildContext context, AsyncSnapshot<Product?> snapshot) {
                if (snapshot.hasError) {
                  return const Text('Errore');
                }

                if (!snapshot.hasData || snapshot.data == null) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    return const Text(
                      'Nessuna informazione per questo articolo',
                      textAlign: TextAlign.center,
                    );
                  } else {
                    return const Text('Loading....');
                  }
                }
                return ProductCard(
                  result: snapshot.data!,
                );
              },
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        shape: const CircleBorder(),
        backgroundColor: Colors.purple,
        onPressed: () => Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const ScannerScreen(),
          ),
        ),
        child: const Icon(
          Icons.cameraswitch_rounded,
          color: Colors.white,
          size: 40,
        ),
      ),
    );
  }
}

class ProductCard extends StatefulWidget {
  const ProductCard({
    super.key,
    required this.result,
  });

  final Product result;

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  bool isNutriScoreExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 12,
      shape: const RoundedRectangleBorder(
        side: BorderSide(
          color: Colors.purple,
        ),
        borderRadius: BorderRadius.all(Radius.circular(24)),
      ),
      shadowColor: Colors.purple,
      surfaceTintColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 24,
        ),
        child: Column(
          children: [
            SizedBox(
              width: double.infinity,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 1,
                    child: _getFrontImageUrl() != null
                        ? Image.network(
                            _getFrontImageUrl()!,
                            fit: BoxFit.contain,
                          )
                        : Image.asset('assets/image-not-found.jpg'),
                  ),
                  Expanded(
                    flex: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Align(
                            alignment: Alignment.center,
                            child: Text(
                              _getProductTitle(),
                              style: Theme.of(context).textTheme.headlineLarge,
                            ),
                          ),
                          const SizedBox(
                            height: 4,
                          ),
                          if (widget.result.barcode != null)
                            RichText(
                              text: TextSpan(
                                style: const TextStyle(
                                    color: Colors.black, fontSize: 18),
                                children: [
                                  const WidgetSpan(
                                    child: Padding(
                                      padding: EdgeInsets.only(right: 8.0),
                                      child: Icon(Icons.barcode_reader),
                                    ),
                                  ),
                                  TextSpan(
                                      text: 'EAN ${widget.result.barcode}'),
                                ],
                              ),
                            ),
                          const SizedBox(
                            height: 4,
                          ),
                          if (widget.result.genericName != null &&
                              widget.result.genericName != '')
                            Text('NOME GENERICO: ${widget.result.genericName}'),
                          const SizedBox(
                            height: 4,
                          ),
                          Text('AZIENDA: ${widget.result.brands}'),
                          const SizedBox(
                            height: 4,
                          ),
                          Text('QUANTITA\': ${widget.result.quantity}'),
                          const SizedBox(
                            height: 4,
                          ),
                          Text('CATEGORIE:\n${_getCategories()}'),
                          const SizedBox(
                            height: 4,
                          ),
                          if (widget.result.website != null)
                            RichText(
                              text: TextSpan(
                                style: const TextStyle(
                                  color: Colors.blue,
                                  decoration: TextDecoration.underline,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                                text: '${widget.result.website}',
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () async {
                                    var uri = Uri.tryParse(
                                        '${widget.result.website}}');
                                    if (uri != null &&
                                        await canLaunchUrl(uri)) {
                                      await launchUrl(uri);
                                    }
                                  },
                              ),
                            )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(
              thickness: 2,
              color: Colors.purple,
              height: 40,
            ),
            _IngredientsSectionWidget(product: widget.result),
            const Divider(
              thickness: 2,
              color: Colors.purple,
              height: 40,
            ),
            if (widget.result.nutritionData != null &&
                widget.result.nutriscore != null)
              _ExpandableScoreWidget(
                result: widget.result,
                imagePath: widget.result.getNutriscoreImagePath(),
                firstChildWidgetList: _getNutriScoreList(),
              ),
            Divider(
              thickness: 1,
              color: Colors.purple.shade100,
            ),
            if (widget.result.ecoscoreGrade != null)
              _ExpandableScoreWidget(
                result: widget.result,
                imagePath: widget.result.getEcoScoreImagePath(),
                firstChildWidgetList: _getEcoScoreList(),
              ),
            Divider(
              thickness: 1,
              color: Colors.purple.shade100,
            ),
            if (widget.result.novaGroup != null)
              _ExpandableScoreWidget(
                result: widget.result,
                imagePath: widget.result.getNovaDataImagePath(),
                firstChildWidgetList: _getNovaDataList(),
              ),
          ],
        ),
      ),
    );
  }

  String? _getFrontImageUrl() {
    List<ProductImage>? mainImages = widget.result.getMainImages();

    if (mainImages != null) {
      List<ProductImage>? mainFrontImages = mainImages
          .where((element) => element.field! == ImageField.FRONT)
          .toList();

      if (mainFrontImages.isNotEmpty) {
        Map<OpenFoodFactsLanguage, List<ProductImage>> imagesMap =
            imagesToLanguageMap(mainFrontImages);

        return _getImageUrlOfLanguage(
                imagesMap, OpenFoodFactsLanguage.ITALIAN) ??
            _getImageUrlOfLanguage(imagesMap, OpenFoodFactsLanguage.ENGLISH) ??
            widget.result.imageFrontUrl!;
      }
    }

    return null;
  }

  String _getProductTitle() {
    if (widget.result.productNameInLanguages != null &&
        widget.result.productNameInLanguages![OpenFoodFactsLanguage.ITALIAN] !=
            null &&
        !widget.result.productNameInLanguages![OpenFoodFactsLanguage.ITALIAN]!
            .trim()
            .isNotEmpty) {
      return widget
          .result.productNameInLanguages![OpenFoodFactsLanguage.ITALIAN]!;
    } else if (widget.result.genericName != null &&
        widget.result.genericName!.trim().isNotEmpty) {
      return widget.result.genericName!;
    } else if (widget.result.productName != null &&
        widget.result.productName!.trim().isNotEmpty) {
      return widget.result.productName!;
    } else if (widget.result.brands != null &&
        widget.result.brands!.isNotEmpty) {
      return widget.result.brands!;
    } else {
      return 'Nessun nome';
    }
  }

  String? _getCategories() {
    Map<OpenFoodFactsLanguage, List<String>>? categoriesMapInLanguages =
        widget.result.categoriesTagsInLanguages;

    if (categoriesMapInLanguages != null &&
        categoriesMapInLanguages.isNotEmpty) {
      if (categoriesMapInLanguages.containsKey(OpenFoodFactsLanguage.ITALIAN)) {
        return _reduceCategoriesMap(
            categoriesMapInLanguages, OpenFoodFactsLanguage.ITALIAN);
      }

      if (categoriesMapInLanguages.containsKey(OpenFoodFactsLanguage.ENGLISH)) {
        return _reduceCategoriesMap(
            categoriesMapInLanguages, OpenFoodFactsLanguage.ENGLISH);
      }
    }

    if (widget.result.categoriesTags != null &&
        widget.result.categoriesTags!.isNotEmpty) {
      if (widget.result.categoriesTags!
              .firstWhereOrNull((element) => element.startsWith('it')) !=
          null) {
        return _reduceCategoriesTags(widget.result.categoriesTags!, 'it');
      }

      if (widget.result.categoriesTags!
              .firstWhereOrNull((element) => element.startsWith('en')) !=
          null) {
        return _reduceCategoriesTags(widget.result.categoriesTags!, 'en');
      }
    }

    return widget.result.categories;
  }

  String _reduceCategoriesMap(
      Map<OpenFoodFactsLanguage, List<String>> categoriesMapInLanguages,
      OpenFoodFactsLanguage language) {
    return categoriesMapInLanguages[language]!
        .reduce((value, element) => value += element);
  }

  String _reduceCategoriesTags(
      List<String> categoriesTags, String languageOffTag) {
    return categoriesTags
        .where((element) => element.startsWith("$languageOffTag:"))
        .map((e) => e.split(':')[1])
        .reduce((value, element) => value += element);
  }

  Iterable<Widget> _getNutriScoreList() {
    String? nutritionImage =
        _getNutritionImageUrl(widget.result.selectedImages);

    return [
      nutritionImage != null
          ? InteractiveViewer(
              panEnabled: false,
              boundaryMargin: const EdgeInsets.all(100),
              minScale: 1,
              maxScale: 3,
              child: Image.network(nutritionImage),
            )
          : Image.asset('assets/image-not-found.jpg'),
      ...widget.result.nutrientLevels!.levels.entries.map(
        (e) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: e.value.getNutrientLevelColor(),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    '${e.key}: ${e.value.value} (${widget.result.nutriments!.getValue(Nutrient.fromOffTag(e.key)!, PerSize.oneHundredGrams)}%)',
                    softWrap: true,
                    overflow: TextOverflow.clip,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ];
  }

  String? _getNutritionImageUrl(List<ProductImage>? selectedImage) {
    if (selectedImage != null) {
      List<ProductImage> nutritionImages = selectedImage
          .where((element) => element.field == ImageField.NUTRITION)
          .toList();

      if (nutritionImages.isEmpty) {
        return null;
      }

      ProductImage? displayImage = nutritionImages
          .firstWhereOrNull((element) => element.size == ImageSize.DISPLAY);

      if (displayImage != null) {
        return displayImage.url;
      }

      ProductImage? smallImage = nutritionImages
          .firstWhereOrNull((element) => element.size == ImageSize.SMALL);

      if (smallImage != null) {
        return smallImage.url;
      }

      ProductImage? thumbImage = nutritionImages
          .firstWhereOrNull((element) => element.size == ImageSize.THUMB);

      if (thumbImage != null) {
        return thumbImage.url;
      }
    }

    return null;
  }

  Iterable<Widget> _getEcoScoreList() {
    String? ecoscoreImage = _getEcoScoreImageUrl(widget.result.selectedImages);

    return [
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: ecoscoreImage != null
            ? InteractiveViewer(
                panEnabled: false,
                boundaryMargin: const EdgeInsets.all(100),
                minScale: 1,
                maxScale: 3,
                child: Image.network(ecoscoreImage),
              )
            : Image.asset('assets/image-not-found.jpg'),
      ),
      ...widget.result.packagings!.map(
        (e) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                e.getPackagingText(),
              ),
            ),
          ),
        ),
      ),
    ];
  }

  String? _getEcoScoreImageUrl(List<ProductImage>? selectedImage) {
    if (selectedImage != null) {
      List<ProductImage> ecoScoreImages = selectedImage
          .where((element) => element.field == ImageField.PACKAGING)
          .toList();
      if (ecoScoreImages.isEmpty) {
        return null;
      }

      ProductImage? displayImage = ecoScoreImages
          .firstWhereOrNull((element) => element.size == ImageSize.DISPLAY);

      if (displayImage != null) {
        return displayImage.url;
      }

      ProductImage? smallImage = ecoScoreImages
          .firstWhereOrNull((element) => element.size == ImageSize.SMALL);

      if (smallImage != null) {
        return smallImage.url;
      }

      ProductImage? thumbImage = ecoScoreImages
          .firstWhereOrNull((element) => element.size == ImageSize.THUMB);

      if (thumbImage != null) {
        return thumbImage.url;
      }
    }

    return null;
  }

  Iterable<Widget> _getNovaDataList() {
    String? nutrientsImage =
        _getNutrientsImageUrl(widget.result.selectedImages);

    return [
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: nutrientsImage != null
            ? InteractiveViewer(
                panEnabled: false,
                boundaryMargin: const EdgeInsets.all(100),
                minScale: 1,
                maxScale: 3,
                child: Image.network(nutrientsImage),
              )
            : Image.asset('assets/image-not-found.jpg'),
      ),
      const Align(
        alignment: Alignment.centerLeft,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.0),
          child: Text(
            'ADDITIVI',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      if (widget.result.additives!.names.isEmpty)
        const Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Text('Nessun additivo da segnalare'),
          ),
        ),
      ...widget.result.additives!.names.map(
        (e) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: RichText(
                text: TextSpan(
                  style: const TextStyle(color: Colors.black, fontSize: 18),
                  children: [
                    const WidgetSpan(
                      alignment: PlaceholderAlignment.middle,
                      child: Padding(
                        padding: EdgeInsets.only(right: 8.0),
                        child: Icon(
                          Icons.circle,
                          size: 12,
                        ),
                      ),
                    ),
                    TextSpan(text: e),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      const SizedBox(
        height: 4,
      ),
      const Align(
        alignment: Alignment.centerLeft,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.0),
          child: Text(
            'ANALISI INGREDIENTI',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      _ingredientsAnalysisWidget(
          'assets/palm-oil.png',
          _getPalmOilInfo(widget
              .result.ingredientsAnalysisTags!.palmOilFreeStatus!.offTag
              .split(':')[1])),
      _ingredientsAnalysisWidget(
          'assets/vegan.png',
          _getVeganInfo(widget
              .result.ingredientsAnalysisTags!.veganStatus!.offTag
              .split(':')[1])),
      _ingredientsAnalysisWidget(
          'assets/vegetarian.png',
          _getVegetarianInfo(widget
              .result.ingredientsAnalysisTags!.vegetarianStatus!.offTag
              .split(':')[1])),
    ];
  }

  String? _getNutrientsImageUrl(List<ProductImage>? selectedImage) {
    List<ProductImage>? mainImages = widget.result.getMainImages();

    if (mainImages != null) {
      List<ProductImage>? nutrientsImages = mainImages
          .where((element) => element.field! == ImageField.NUTRITION)
          .toList();

      if (nutrientsImages.isNotEmpty) {
        Map<OpenFoodFactsLanguage, List<ProductImage>> imagesMap =
            imagesToLanguageMap(nutrientsImages);

        return _getImageUrlOfLanguage(
                imagesMap, OpenFoodFactsLanguage.ITALIAN) ??
            _getImageUrlOfLanguage(imagesMap, OpenFoodFactsLanguage.ENGLISH) ??
            widget.result.imageFrontUrl!;
      }
    }

    return null;
  }

  Widget _ingredientsAnalysisWidget(
      String imagePath, Iterable<InlineSpan> analysisText) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Image.asset(imagePath),
          ),
          RichText(
            text: TextSpan(
              style: const TextStyle(color: Colors.black, fontSize: 18),
              children: [
                TextSpan(children: [...analysisText]),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Iterable<InlineSpan> _getPalmOilInfo(String palmOilFreeStatus) {
    bool isPalmOilFree = palmOilFreeStatus == 'palm-oil-free';
    return [
      TextSpan(
        text:
            isPalmOilFree ? 'Senza olio di palma' : 'Contenente olio di palma',
        style: TextStyle(
          color: isPalmOilFree ? Colors.black : Colors.red,
          fontWeight: FontWeight.bold,
        ),
      ),
      if (!isPalmOilFree)
        const TextSpan(
          text: '\n(o info sconosciuta)',
          style: TextStyle(
            color: Colors.red,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
    ];
  }

  Iterable<InlineSpan> _getVeganInfo(String veganStatus) {
    bool isVegan = veganStatus == 'vegan';
    return [
      TextSpan(
        text: isVegan ? 'Vegano' : 'Non vegano',
        style: TextStyle(
          color: isVegan ? Colors.black : Colors.red,
          fontWeight: FontWeight.bold,
        ),
      ),
      if (!isVegan)
        const TextSpan(
          text: '\n(o info sconosciuta)',
          style: TextStyle(
            color: Colors.red,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
    ];
  }

  Iterable<InlineSpan> _getVegetarianInfo(String vegegetarianStatus) {
    bool isVegetarian = vegegetarianStatus == 'vegan';
    return [
      TextSpan(
        text: isVegetarian ? 'Vegetariano' : 'Non vegetariano',
        style: TextStyle(
          color: isVegetarian ? Colors.black : Colors.red,
          fontWeight: FontWeight.bold,
        ),
      ),
      if (!isVegetarian)
        const TextSpan(
          text: '\n(o info sconosciuta)',
          style: TextStyle(
            color: Colors.red,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
    ];
  }
}

String? _getImageUrlOfLanguage(
    Map<OpenFoodFactsLanguage, List<ProductImage>> imagesMap,
    OpenFoodFactsLanguage language) {
  if (imagesMap.containsKey(language)) {
    List<ProductImage> imagesList = imagesMap[language]!;

    return imagesList
        .firstWhere(
          (element) => element.size == ImageSize.DISPLAY,
          orElse: () => imagesList.firstWhere(
              (element) => element.size == ImageSize.SMALL,
              orElse: () => imagesList
                  .firstWhere((element) => element.size == ImageSize.THUMB)),
        )
        .url!;
  }

  return null;
}

Map<OpenFoodFactsLanguage, List<ProductImage>> imagesToLanguageMap(
    List<ProductImage> images) {
  Map<OpenFoodFactsLanguage, List<ProductImage>> response = {};

  for (ProductImage image in images) {
    if (!response.containsKey(image.language)) {
      response[image.language!] = [];
    }

    response[image.language]!.add(image);
  }

  return response;
}

class _IngredientsSectionWidget extends StatelessWidget {
  const _IngredientsSectionWidget({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('INGREDIENTI', style: Theme.of(context).textTheme.headlineMedium),
        _getIngredientsImageUrl() != null
            ? InteractiveViewer(
                panEnabled: false,
                boundaryMargin: const EdgeInsets.all(100),
                minScale: 1,
                maxScale: 3,
                child: Image.network(
                  _getIngredientsImageUrl()!,
                  fit: BoxFit.contain,
                ),
              )
            : Image.asset('assets/image-not-found.jpg'),
        if (product.ingredients != null)
          Align(
            alignment: Alignment.centerLeft,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...product.ingredients!.map(
                  (e) => ExpansionTile(
                    leading: const Icon(Icons.circle, size: 16),
                    expandedAlignment: Alignment.centerLeft,
                    title: Text(
                      e.text ?? e.id ?? e.id!,
                      style: const TextStyle(
                        color: Colors.black,
                      ),
                    ),
                    subtitle: Text(
                      '${e.percent ?? e.percentEstimate}%',
                      style: const TextStyle(color: Colors.blue),
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 54),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _ingredientItemList(
                              'assets/vegan.png',
                              e.vegan ==
                                      IngredientSpecialPropertyStatus.POSITIVE
                                  ? 'Vegano'
                                  : 'Non vegano',
                            ),
                            _ingredientItemList(
                              'assets/vegetarian.png',
                              e.vegetarian ==
                                      IngredientSpecialPropertyStatus.POSITIVE
                                  ? 'Vegetariano'
                                  : 'Non vegetariano',
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _ingredientItemList(String iconPath, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: RichText(
        text: TextSpan(
          children: [
            WidgetSpan(
              child: Image.asset(
                iconPath,
                height: 18,
              ),
            ),
            TextSpan(
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                ),
                text: text),
          ],
        ),
      ),
    );
  }

  String? _getIngredientsImageUrl() {
    List<ProductImage>? mainImages = product.getMainImages();

    if (mainImages != null) {
      List<ProductImage>? mainFrontImages = mainImages
          .where((element) => element.field! == ImageField.INGREDIENTS)
          .toList();

      if (mainFrontImages.isNotEmpty) {
        Map<OpenFoodFactsLanguage, List<ProductImage>> imagesMap =
            imagesToLanguageMap(mainFrontImages);

        return _getImageUrlOfLanguage(
                imagesMap, OpenFoodFactsLanguage.ITALIAN) ??
            _getImageUrlOfLanguage(imagesMap, OpenFoodFactsLanguage.ENGLISH) ??
            product.imageFrontUrl!;
      }
    }

    return null;
  }
}

class _ExpandableScoreWidget extends StatefulWidget {
  const _ExpandableScoreWidget({
    required this.result,
    required this.imagePath,
    required this.firstChildWidgetList,
  });

  final Product result;
  final String imagePath;
  final Iterable<Widget> firstChildWidgetList;

  @override
  State<_ExpandableScoreWidget> createState() => _ExpandableScoreWidgetState();
}

class _ExpandableScoreWidgetState extends State<_ExpandableScoreWidget> {
  bool isNutriScoreExpanded = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedCrossFade(
      duration: const Duration(milliseconds: 300),
      firstChild: InkWell(
        splashFactory: NoSplash.splashFactory,
        onDoubleTap: () => setState(() {
          isNutriScoreExpanded = false;
        }),
        child: SizedBox(
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                widget.imagePath,
              ),
              ...widget.firstChildWidgetList.toList(),
            ],
          ),
        ),
      ),
      secondChild: InkWell(
        splashFactory: NoSplash.splashFactory,
        onTap: () => setState(() {
          isNutriScoreExpanded = true;
        }),
        child: SizedBox(
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                widget.imagePath,
              ),
            ],
          ),
        ),
      ),
      crossFadeState: isNutriScoreExpanded
          ? CrossFadeState.showFirst
          : CrossFadeState.showSecond,
    );
  }
}
