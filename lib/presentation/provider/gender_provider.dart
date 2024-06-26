import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GenderProvider with ChangeNotifier {
  bool _isMan;

  GenderProvider({required bool isMan}) : _isMan = isMan {
    _loadState();
  }

  bool get isMan => _isMan;

  set isMan(bool newValue) {
    _isMan = newValue;
    _saveState();
    notifyListeners();
  }

  Future<void> _loadState() async {
    final prefs = await SharedPreferences.getInstance();
    _isMan = prefs.getBool('isMan') ?? true;
    notifyListeners();
  }

  Future<void> _saveState() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('isMan', _isMan);
  }
}
