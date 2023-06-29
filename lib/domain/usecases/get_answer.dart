import 'package:chatbot/core/error/failures.dart';
import 'package:chatbot/domain/entities/answer_entity.dart';
import 'package:chatbot/domain/entities/chat_message_entity.dart';
import 'package:chatbot/domain/repositories/api_repository.dart';
import 'package:dartz/dartz.dart';

class GetAnswer {
  final ApiRepository apiRepository;

  GetAnswer(this.apiRepository);

  Future<Either<Failure, AnswerEntity>> execute(
      List<ChatMessage> messages) async {
    return await apiRepository.getAnswer(messages);
  }
}
