import 'package:my_family_app/models/event_info.dart';

Map<String, Object> convertDynamicMap(Map<String, dynamic> map) {
  Map<String, Object> result = {};
  map.forEach((key, value) {
    if (value is DateTime) {
      result[key] = value.toIso8601String();
    } else if (value is EventInfo) {
      result[key] = value.toJson();
    } else {
      result[key] = value;
    }
  });
  return result;
}
