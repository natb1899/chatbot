import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ModelProvider with ChangeNotifier {
  String _model;

  ModelProvider({required String model}) : _model = model {
    _loadState();
  }

  String get model => _model;

  set setModel(String newValue) {
    _model = newValue;
    _saveState();
    notifyListeners();
  }

  Future<void> _loadState() async {
    final prefs = await SharedPreferences.getInstance();
    _model = prefs.getString('model') ?? 'gpt-3.5-turbo';
    notifyListeners();
  }

  Future<void> _saveState() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('model', _model);
  }
}
