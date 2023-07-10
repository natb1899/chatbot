import 'package:chatbot/domain/entities/answer_entity.dart';

class AnswerModel extends AnswerEntity {
  AnswerModel({required super.answer});

  factory AnswerModel.fromJson(Map<String, dynamic> json) {
    return AnswerModel(answer: json['choices'][0]['message']['content']);
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'answer': answer,
    };
  }
}
