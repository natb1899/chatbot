import 'package:chatbot/domain/entities/transcription_entity.dart';

class TranscriptionModel extends TranscriptionEntity {
  TranscriptionModel({required super.transcript});

  factory TranscriptionModel.fromJson(Map<String, dynamic> json) {
    return TranscriptionModel(
      transcript: json['text'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'transcript': transcript,
    };
  }
}
