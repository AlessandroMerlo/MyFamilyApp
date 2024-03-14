import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';

extension NutrientLevelX on NutrientLevel {
  static Map<String, Color> nutrientsLevelColors = {
    'high': Colors.red[700]!,
    'moderate': Colors.yellow[700]!,
    'low': Colors.green[700]!
  };

  Color getNutrientLevelColor() {
    return nutrientsLevelColors[offTag] ?? Colors.black;
  }
}
