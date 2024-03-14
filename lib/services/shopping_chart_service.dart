import 'package:my_family_app/data/database.dart';
import 'package:my_family_app/models/shopping_chart.dart';
import 'package:my_family_app/utils/constants.dart';

const String path = 'shopping_charts';

Future<DatabaseCallStatus> createShoppingChart(
    {required ShoppingChart newShoppingChart}) async {
  return await FireBaseRealTimeDatabase.create(
    path: path,
    newObject: newShoppingChart.toJson(),
  );
}

Future<DatabaseCallStatus> updateShoppingChart(
    {required ShoppingChartData newShoppingChartData}) async {
  return await FireBaseRealTimeDatabase.update(
    path: path,
    key: newShoppingChartData.key,
    newObject: newShoppingChartData.shoppingChart.toJson(),
  );
}

Future<DatabaseCallStatus> deleteShoppingChart({required String key}) async {
  return await FireBaseRealTimeDatabase.delete(
    path: path,
    key: key,
  );
}
