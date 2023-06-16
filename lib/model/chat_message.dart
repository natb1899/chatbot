enum ChatType { user, assistent, system }

class ChatMessage {
  String? transcript;
  ChatType type;

  Map<String, String> toJson() {
    return {'role': ChatType.user.name, 'content': transcript!};
  }

  ChatMessage({this.transcript, required this.type});
}
