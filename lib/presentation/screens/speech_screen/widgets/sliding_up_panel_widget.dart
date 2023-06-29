import 'package:chatbot/data/datasources/firebase/firestore.dart';
import 'package:chatbot/domain/entities/chat_message_entity.dart';
import 'package:chatbot/presentation/provider/chat_provider.dart';
import 'package:chatbot/presentation/screens/speech_screen/widgets/chat_bubble.dart';
import 'package:chatbot/presentation/screens/speech_screen/widgets/typing_animation.dart';
import 'package:chatbot/utils/helper_widgets.dart';
import 'package:flutter/material.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class SlidingPanel extends StatelessWidget {
  final ScrollController controller;
  final PanelController panelController;
  final String? transcript;
  final bool? isSending;
  final ChatProvider chatProvider;
  final List<ChatMessage> messages;

  const SlidingPanel(
      {super.key,
      required this.controller,
      required this.panelController,
      this.transcript,
      this.isSending,
      required this.chatProvider,
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () {
                        panelController.close();
                      },
                      icon: const Icon(
                        Icons.close_outlined,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      chatProvider.chatID == ""
                          ? "New Chat"
                          : chatProvider.chatID,
                      style: Theme.of(context).textTheme.displaySmall,
                    ),
                    messages.isEmpty
                        ? IconButton(
                            onPressed: () {
                              panelController.close();
                            },
                            icon: const Icon(
                              Icons.close_outlined,
                              color: Colors.white,
                            ),
                          )
                        : PopupMenuButton(
                            onSelected: (value) async {
                              if (value == "save") {
                                chatProvider.setChatId(
                                  await FirestoreService().saveChatMessages(
                                      chatProvider.chatID, messages),
                                );
                              } else if (value == "delete") {
                                chatProvider.chatID == ""
                                    ? messages.clear()
                                    : messages.clear();
                                await FirestoreService()
                                    .deleteChatMessages(chatProvider.chatID);
                                chatProvider.setChatId("");
                              }
                            },
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                value: "save",
                                child: Text("Save Chat"),
                              ),
                              const PopupMenuItem(
                                value: "delete",
                                child: Text("Delete Chat"),
                              )
                            ],
                          ),
                  ],
                ),
              ],
            ),
          ),
          const VerticalSpace(20),
        ],
      );

  Widget buildChat(BuildContext context) {
    final chatScrollController = ScrollController();
    return Column(
      children: [
        messages.isEmpty
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
      ],
    );
  }
}
