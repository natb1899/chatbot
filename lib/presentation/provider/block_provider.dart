import 'package:flutter/material.dart';

class BlockProvider extends ChangeNotifier {
  bool _isBlocked = false;

  bool get isBlocked => _isBlocked;

  set isBlocked(bool value) {
    _isBlocked = value;
    notifyListeners();
  }
}
