import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider with ChangeNotifier {
  String _language;

  LanguageProvider({required String language}) : _language = language {
    _loadState();
  }

  String get language => _language;

  set setLanguage(String newValue) {
    _language = newValue;
    _saveState();
    notifyListeners();
  }

  Future<void> _loadState() async {
    final prefs = await SharedPreferences.getInstance();
    _language = prefs.getString('language') ?? 'english';
    notifyListeners();
  }

  Future<void> _saveState() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('language', _language);
  }
}
