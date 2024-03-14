class WhatWhereData {
  final String key;
  final WhatWhere whatWhere;

  WhatWhereData({
    required this.key,
    required this.whatWhere,
  });
}

class WhatWhere {
  final String what;
  final String where;
  final DateTime when;

  WhatWhere({
    required this.what,
    required this.where,
    when,
  }) : when = when == '' ? when : DateTime.now();

  Map<String, Object> toJson() => {
        'what': what,
        'where': where,
        'when': when.toUtc().toIso8601String(),
      };

  WhatWhere.fromJson(Map<dynamic, dynamic> json)
      : what = json['what'],
        where = json['where'],
        when = DateTime.parse(json['when'] as String).toLocal();
}
