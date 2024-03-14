import 'package:my_family_app/data/database.dart';
import 'package:my_family_app/models/freezer_item.dart';
import 'package:my_family_app/utils/constants.dart';

const String path = 'freezer_items';

Future<DatabaseCallStatus> createFreezerItem(
    {required FreezerItem newFreezerItem}) async {
  return await FireBaseRealTimeDatabase.create(
    path: path,
    newObject: newFreezerItem.toJson(),
  );
}

Future<DatabaseCallStatus> updateFreezerItem(
    {required FreezerItemData newFreezerItem}) async {
  return await FireBaseRealTimeDatabase.update(
    path: path,
    key: newFreezerItem.key,
    newObject: newFreezerItem.freezerItem.toJson(),
  );
}

Future<DatabaseCallStatus> deleteFreezerItem({required String key}) async {
  return await FireBaseRealTimeDatabase.delete(
    path: path,
    key: key,
  );
}
