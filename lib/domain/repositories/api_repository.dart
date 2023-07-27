import 'package:chatbot/core/error/failures.dart';
import 'package:chatbot/domain/entities/answer_entity.dart';
import 'package:chatbot/domain/entities/chat_message_entity.dart';
import 'package:chatbot/domain/entities/speech_entity.dart';
import 'package:chatbot/domain/entities/transcription_entity.dart';
import 'package:dartz/dartz.dart';

abstract class ApiRepository {
  Future<Either<Failure, TranscriptionEntity>> getTranscription(String path);
  Future<Either<Failure, AnswerEntity>> getAnswer(
      List<ChatMessage> messages, String model);
  Future<Either<Failure, SpeechEntity>> getSpeech(
      String answer, bool isMan, String language);
}
