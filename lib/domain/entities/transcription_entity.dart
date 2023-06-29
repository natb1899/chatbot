class TranscriptionEntity {
  String transcript;

  TranscriptionEntity({
    required this.transcript,
  });

  factory TranscriptionEntity.fromJson(Map<String, dynamic> json) {
    return TranscriptionEntity(
      transcript: json['transcript'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'transcript': transcript,
    };
  }
}
