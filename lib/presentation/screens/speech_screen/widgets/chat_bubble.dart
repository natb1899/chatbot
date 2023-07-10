import 'package:chatbot/domain/entities/chat_message_entity.dart';
import 'package:chatbot/utils/helper_widgets.dart';
import 'package:flutter/material.dart';

class ChatBubble extends StatelessWidget {
  final String? transcript;
  final String? model;
  final ChatType type;

  const ChatBubble(
      {super.key, this.transcript, this.model, required this.type});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: ChatType.assistent == type
          ? Alignment.centerLeft
          : Alignment.centerRight,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        margin: const EdgeInsets.only(bottom: 10.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: ChatType.assistent == type
              ? botChatBubble(context)
              : userChatBubble(context),
        ),
      ),
    );
  }

  List<Widget> userChatBubble(BuildContext context) {
    return [
      Expanded(
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
            borderRadius: BorderRadius.circular(10),
          ),
          child: transcript == null
              ? Container()
              : Text(transcript!, style: Theme.of(context).textTheme.bodySmall),
        ),
      ),
      const HorizontalSpace(12),
      CircleAvatar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: const Icon(Icons.person_outlined, color: Colors.white),
      ),
    ];
  }

  List<Widget> botChatBubble(BuildContext context) {
    return [
      CircleAvatar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: const Icon(Icons.rocket_launch_outlined, color: Colors.white),
      ),
      const HorizontalSpace(12),
      Expanded(
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.7),
            borderRadius: BorderRadius.circular(10),
          ),
          child: transcript == null
              ? Container()
              : Text(transcript!, style: Theme.of(context).textTheme.bodySmall),
        ),
      ),
    ];
  }
}
