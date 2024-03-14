import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_family_app/data/database.dart';
import 'package:my_family_app/models/shopping_chart.dart';

const String path = 'shopping_charts';

final DatabaseReference _databaseRef = FireBaseRealTimeDatabase.database.ref();

final shoppingChartStreamProvider =
    StreamProvider<List<ShoppingChartData>>((ref) {
  final streamController = StreamController<List<ShoppingChartData>>();

  final shoppingChartList = <ShoppingChartData>[];

  Query query = _databaseRef.child(path);

  query.onChildAdded.listen((event) {
    ShoppingChart shoppingChart =
        ShoppingChart.fromJson(event.snapshot.value as Map);
    ShoppingChartData shoppingChartData = ShoppingChartData(
        key: event.snapshot.key!, shoppingChart: shoppingChart);

    shoppingChartList.add(shoppingChartData);
    streamController.add(shoppingChartList);
  });

  query.onChildRemoved.listen((event) {
    shoppingChartList
        .removeWhere((element) => element.key == event.snapshot.key);
    streamController.add(shoppingChartList);
  });

  query.onChildChanged.listen((event) {
    ShoppingChart updatedShoppingChart =
        ShoppingChart.fromJson(event.snapshot.value as Map);
    ShoppingChartData updatedShoppingChartData = ShoppingChartData(
        key: event.snapshot.key!, shoppingChart: updatedShoppingChart);

    int indexOf = shoppingChartList
        .indexWhere((element) => element.key == event.snapshot.key);

    if (indexOf != -1) {
      shoppingChartList[indexOf] = updatedShoppingChartData;
      streamController.add(shoppingChartList);
    }
  });

  return streamController.stream;
});
