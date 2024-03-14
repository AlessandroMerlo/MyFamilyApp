import 'package:flutter/material.dart';

class SelectedIcon with ChangeNotifier {
  int selectedIndex = 0;

  void changeIndex(int index) {
    if (selectedIndex != index) {
      selectedIndex = index;
      notifyListeners();
    }
  }
}
