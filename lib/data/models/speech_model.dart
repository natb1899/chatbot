import 'package:chatbot/domain/entities/speech_entity.dart';

class SpeechModel extends SpeechEntity {
  SpeechModel({required super.file, required super.visemes});

  factory SpeechModel.fromJson(Map<String, dynamic> json) {
    return SpeechModel(
      file: json['file'],
      visemes: json['visemes'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'file': file,
      'visemes': visemes,
    };
  }
}
