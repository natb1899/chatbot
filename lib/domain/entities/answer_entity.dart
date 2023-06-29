class AnswerEntity {
  String answer;

  AnswerEntity({
    required this.answer,
  });

  factory AnswerEntity.fromJson(Map<String, dynamic> json) {
    return AnswerEntity(
      answer: json['answer'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'answer': answer,
    };
  }
}
