import 'package:chatbot/core/error/failures.dart';
import 'package:chatbot/domain/entities/speech_entity.dart';
import 'package:chatbot/domain/repositories/api_repository.dart';
import 'package:dartz/dartz.dart';

class GetSpeech {
  final ApiRepository apiRepository;

  GetSpeech(this.apiRepository);

  Future<Either<Failure, SpeechEntity>> execute(
      String answer, bool isMan) async {
    String formattedAnswer = answer.replaceAll('\n', '');
    return await apiRepository.getSpeech(formattedAnswer, isMan);
  }
}
