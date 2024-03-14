import 'package:my_family_app/data/database.dart';
import 'package:my_family_app/models/users.dart';
import 'package:my_family_app/utils/constants.dart';
import 'package:my_family_app/utils/converter.dart';

const String path = 'users';

final List<MyUser> myUsersList = [];

Future<void> loadUsers() async {
  var users = await FireBaseRealTimeDatabase.getUsers();
  for (var user in users.values) {
    myUsersList.add(MyUser.fromJson(user));
  }
}

Future<void> reloadUsers() async {
  myUsersList.clear();
  var users = await FireBaseRealTimeDatabase.getUsers();
  for (var user in users.values) {
    myUsersList.add(MyUser.fromJson(user));
  }
}

Future<Map<dynamic, dynamic>> getUsers() async {
  var snapshot =
      await FireBaseRealTimeDatabase.database.ref().child('users').once();

  return Map<dynamic, dynamic>.from(snapshot.snapshot.value as Map);
}

Future<String> getUserKey({required String userUid}) async {
  var snapshot =
      await FireBaseRealTimeDatabase.database.ref().child('users').get();

  var myUsersData = Map<dynamic, dynamic>.from(snapshot.value as Map);

  for (var userEntries in myUsersData.entries) {
    if (userEntries.value['id'] == userUid) {
      return userEntries.key;
    }
  }

  return '';
}

Future<DatabaseCallStatus> saveUser({required MyUser myUser}) async {
  return await FireBaseRealTimeDatabase.create(
    path: path,
    newObject: convertDynamicMap(myUser.toJson()),
  );
}

Future<DatabaseCallStatus> updateUser(
    {required MyUser myUser, required String key}) async {
  return await FireBaseRealTimeDatabase.update(
    path: path,
    key: key,
    newObject: convertDynamicMap(myUser.toJson()),
  );
}
