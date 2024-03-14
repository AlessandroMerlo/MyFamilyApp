import 'package:openfoodfacts/openfoodfacts.dart';

extension ProductPackagingX on ProductPackaging {
  String getPackagingText() {
    String response = '';

    if (numberOfUnits != null) {
      response += '$numberOfUnits \u00D7 ';
    }

    if (shape != null && shape!.id != null) {
      response += '${shape!.id!.split(':')[1].toUpperCase()} ';
    }

    String details = '';

    if (material != null && material!.id != null) {
      details += '( ${material!.id!.split(':')[1]} ';
      if (weightMeasured != null) {
        details += '${weightMeasured}gr';
      }

      details += ')';
    }

    return response + details;
  }
}
