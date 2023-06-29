import 'package:chatbot/core/error/failures.dart';
import 'package:chatbot/domain/entities/transcription_entity.dart';
import 'package:chatbot/domain/repositories/api_repository.dart';
import 'package:dartz/dartz.dart';

class GetTranscription {
  final ApiRepository apiRepository;

  GetTranscription(this.apiRepository);

  Future<Either<Failure, TranscriptionEntity>> execute(String path) async {
    return await apiRepository.getTranscription(path);
  }
}
