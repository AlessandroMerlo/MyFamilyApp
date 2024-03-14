class FreezerItemData {
  final String key;
  final FreezerItem freezerItem;

  FreezerItemData({
    required this.key,
    required this.freezerItem,
  });
}

class FreezerItem {
  final String name;
  final String quantity;
  final DateTime frostingDate;
  final DateTime expirationDate;

  FreezerItem({
    required this.name,
    quantity,
    frostingDate,
    required this.expirationDate,
  })  : quantity = quantity == '' ? '1 confezione' : quantity,
        frostingDate = frostingDate ?? DateTime.now();

  Map<String, Object> toJson() => {
        'name': name,
        'quantity': quantity,
        'frostingDate': frostingDate.toUtc().toIso8601String(),
        'expirationDate': expirationDate.toUtc().toIso8601String(),
      };

  FreezerItem.fromJson(Map<dynamic, dynamic> json)
      : name = json['name'],
        quantity = json['quantity'],
        frostingDate = DateTime.parse(json['frostingDate'] as String).toLocal(),
        expirationDate =
            DateTime.parse(json['expirationDate'] as String).toLocal();
}
