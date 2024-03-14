import 'package:flutter/material.dart';

class ShoppingChartData {
  final String key;
  final ShoppingChart shoppingChart;

  ShoppingChartData({
    required this.key,
    required this.shoppingChart,
  });
}

class ShoppingChart {
  final String store;
  final DateTime creationDate;
  final List<Article> articles;

  ShoppingChart({
    store,
    creationDate,
    required this.articles,
  })  : creationDate = creationDate ?? DateTime.now(),
        store = store == '' ? 'Non Specificato' : store;

  Map<String, Object> toJson() => {
        'store': store,
        'creationDate': creationDate.toUtc().toIso8601String(),
        'articles': articles.map((article) => article.toJson()).toList(),
      };

  ShoppingChart.fromJson(Map<dynamic, dynamic> json)
      : store = json['store'],
        creationDate = DateTime.parse(json['creationDate'] as String).toLocal(),
        articles = [
          for (final article in json['articles'])
            Article.fromJson(article as Map)
        ];
}

class Article {
  final String name;
  final String quantity;
  final bool isInSale;
  final String note;
  final bool purchased;

  Article({
    required this.name,
    quantity,
    this.isInSale = false,
    note,
    this.purchased = false,
  })  : quantity = quantity == '' ? '1 pezzo' : quantity,
        note = note ?? '';

  Map<String, Object> toJson() => {
        'name': name,
        'quantity': quantity,
        'isInSale': isInSale,
        'note': note,
        'purchased': purchased,
      };

  Article.fromJson(Map<dynamic, dynamic> json)
      : name = json['name'],
        quantity = json['quantity'],
        isInSale = json['isInSale'],
        note = json['note'],
        purchased = json['purchased'];

  Icon getIsInSaleIcon({required Color color}) => Icon(
        isInSale ? Icons.attach_money : Icons.money_off,
        color: color,
      );
}
