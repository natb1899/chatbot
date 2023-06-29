import 'dart:io';

import 'package:chatbot/domain/entities/viseme_entity.dart';

class SpeechEntity {
  File file;
  List<Viseme> visemes;

  SpeechEntity({
    required this.file,
    required this.visemes,
  });

  factory SpeechEntity.fromJson(Map<String, dynamic> json) {
    return SpeechEntity(
      file: json['file'],
      visemes: json['visemes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'file': file,
      'visemes': visemes,
    };
  }
}
