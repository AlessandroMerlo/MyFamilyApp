import 'package:my_family_app/data/database.dart';
import 'package:my_family_app/models/what_where.dart';
import 'package:my_family_app/utils/constants.dart';

const String path = 'what_where';

Future<DatabaseCallStatus> createWhatWhere(
    {required WhatWhere newWhatWhere}) async {
  return await FireBaseRealTimeDatabase.create(
    path: path,
    newObject: newWhatWhere.toJson(),
  );
}

Future<DatabaseCallStatus> updateWhatWhere(
    {required WhatWhereData newWhatwhereData}) async {
  return await FireBaseRealTimeDatabase.update(
    path: path,
    key: newWhatwhereData.key,
    newObject: newWhatwhereData.whatWhere.toJson(),
  );
}

Future<DatabaseCallStatus> deleteWhatWhere({required String key}) async {
  return await FireBaseRealTimeDatabase.delete(
    path: path,
    key: key,
  );
}
