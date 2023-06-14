enum ChatType { user, assistent, system }

class ChatMessage {
  String? transcript;
  final ChatType type;

  Map<String, String> toJson() {
    return {'role': ChatType.user.name, 'content': transcript!};
  }

  ChatMessage({this.transcript, required this.type});
}
