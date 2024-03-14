import 'package:openfoodfacts/openfoodfacts.dart';

extension ProductX on Product {
  String getNutriscoreImagePath() {
    return 'assets/nutriscore/nutriscore-$nutriscore.png';
  }

  String getNovaDataImagePath() {
    return 'assets/nova-group/nova-group-$novaGroup.png';
  }

  String getEcoScoreImagePath() {
    return 'assets/ecoscore/ecoscore-$ecoscoreGrade.png';
  }
}
