import 'package:chatbot/core/error/failures.dart';
import 'package:chatbot/data/datasources/api_remote_datasource.dart';
import 'package:chatbot/domain/entities/answer_entity.dart';
import 'package:chatbot/domain/entities/chat_message_entity.dart';
import 'package:chatbot/domain/entities/speech_entity.dart';
import 'package:chatbot/domain/entities/transcription_entity.dart';
import 'package:chatbot/domain/repositories/api_repository.dart';
import 'package:dartz/dartz.dart';

class ApiRepositoryImpl implements ApiRepository {
  final ApiRemoteDataSource apiRemoteDataSource;

  ApiRepositoryImpl(this.apiRemoteDataSource);

  @override
  Future<Either<Failure, TranscriptionEntity>> getTranscription(
      String path) async {
    try {
      final getTranscription = await apiRemoteDataSource.getTranscription(path);
      return Right(getTranscription);
    } on UnimplementedError {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, AnswerEntity>> getAnswer(
      List<ChatMessage> messages) async {
    try {
      final getAnswer = await apiRemoteDataSource.getAnswer(messages);
      return Right(getAnswer);
    } on UnimplementedError {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, SpeechEntity>> getSpeech(
      String answer, bool isMan) async {
    try {
      final getSpeech = await apiRemoteDataSource.getSpeech(answer, isMan);
      return Right(getSpeech);
    } on UnimplementedError {
      return Left(ServerFailure());
    }
  }
}
