import 'package:flutter/material.dart';

class SendingProvider extends ChangeNotifier {
  bool _isSending = false;

  bool get isSending => _isSending;

  set isSending(bool value) {
    _isSending = value;
    notifyListeners();
  }
}
