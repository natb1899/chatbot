import 'package:chatbot/utils/helper_widgets.dart';
import 'package:chatbot/widgets/chat_bubble.dart';
import 'package:chatbot/model/chat_message.dart';
import 'package:chatbot/widgets/typing_animation.dart';
import 'package:flutter/material.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class SlidingPanel extends StatelessWidget {
  final ScrollController controller;
  final PanelController panelController;
  final String? transcript;
  final bool? isSending;
  final List<ChatMessage> messages;

  const SlidingPanel(
      {super.key,
      required this.controller,
      required this.panelController,
      this.transcript,
      this.isSending,
      required this.messages});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(left: 12, right: 12, bottom: 80),
      controller: controller,
      children: <Widget>[
        const VerticalSpace(10),
        buildDragHandle(context),
        const VerticalSpace(40),
        buildContent(context),
        const VerticalSpace(10),
        buildChat(context)
      ],
    );
  }

  Widget buildDragHandle(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return GestureDetector(
      onTap: togglePanel,
      child: Center(
        child: Container(
          width: screenWidth,
          height: 5,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }

  void togglePanel() => panelController.isPanelOpen
      ? panelController.close()
      : panelController.open();

  Widget buildContent(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Column(
              children: [
                /*IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () {
                    // Add your onPressed logic here
                  },
                ),
                const VerticalSpace(10),*/
                Text(
                  "Chat",
                  style: Theme.of(context).textTheme.displayLarge,
                ),
              ],
            ),
          ),
          const VerticalSpace(20),
        ],
      );

  Widget buildChat(BuildContext context) {
    final chatScrollController = ScrollController();
    return Expanded(
      child: messages.isEmpty
          ? Column(
              children: [
                const Center(
                  child: Text('Start a new chat to see the chat history'),
                ),
                if (isSending == true)
                  const TypingAnimaton(vertical: 15, horizontal: 0),
              ],
            )
          : SingleChildScrollView(
              child: Column(
                children: [
                  if (isSending == true)
                    const TypingAnimaton(vertical: 15, horizontal: 0),
                  ListView.builder(
                    shrinkWrap: true,
                    itemCount: messages.length,
                    itemBuilder: (BuildContext context, int index) {
                      var chat = messages[index];
                      return ChatBubble(
                        transcript: chat.transcript,
                        type: chat.type,
                      );
                    },
                    controller: chatScrollController,
                  ),
                ],
              ),
            ),
    );
  }
}
