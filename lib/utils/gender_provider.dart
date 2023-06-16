import 'package:flutter/material.dart';

class GenderProvider with ChangeNotifier {
  bool _isMan = true;

  bool get isMan => _isMan;

  set isMan(bool newValue) {
    _isMan = newValue;
    notifyListeners();
  }
}
