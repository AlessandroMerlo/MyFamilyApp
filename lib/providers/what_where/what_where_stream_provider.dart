import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_family_app/data/database.dart';
import 'package:my_family_app/models/what_where.dart';

const String path = 'what_where';

final DatabaseReference _databaseRef = FireBaseRealTimeDatabase.database.ref();

final whatWhereStreamProvider = StreamProvider<List<WhatWhereData>>((ref) {
  final streamController = StreamController<List<WhatWhereData>>();

  final whatWhereList = <WhatWhereData>[];

  Query query = _databaseRef.child(path);

  query.onChildAdded.listen((event) {
    WhatWhere whatWhere = WhatWhere.fromJson(event.snapshot.value as Map);
    WhatWhereData whatWhereData =
        WhatWhereData(key: event.snapshot.key!, whatWhere: whatWhere);

    whatWhereList.add(whatWhereData);
    streamController.add(whatWhereList);
  });

  query.onChildRemoved.listen((event) {
    whatWhereList.removeWhere((element) => element.key == event.snapshot.key);
    streamController.add(whatWhereList);
  });

  query.onChildChanged.listen((event) {
    WhatWhere updatedWhatWhere =
        WhatWhere.fromJson(event.snapshot.value as Map);
    WhatWhereData updatedWhatWhereData =
        WhatWhereData(key: event.snapshot.key!, whatWhere: updatedWhatWhere);

    int indexOf = whatWhereList
        .indexWhere((element) => element.key == event.snapshot.key);

    if (indexOf != -1) {
      whatWhereList[indexOf] = updatedWhatWhereData;
      streamController.add(whatWhereList);
    }
  });

  return streamController.stream;
});
