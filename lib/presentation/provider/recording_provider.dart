import 'package:flutter/material.dart';

class RecordingProvider extends ChangeNotifier {
  bool _isRecording = false;

  bool get isRecording => _isRecording;

  set isRecording(bool value) {
    _isRecording = value;
    notifyListeners();
  }
}
