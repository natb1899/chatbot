import 'package:chatbot/data/datasources/firebase/firestore.dart';
import 'package:chatbot/presentation/provider/chat_provider.dart';
import 'package:chatbot/presentation/screens/speech_screen/widgets/chat_bubble.dart';
import 'package:chatbot/utils/helper_widgets.dart';
import 'package:flutter/material.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class SlidingPanel extends StatelessWidget {
  final ScrollController controller;
  final PanelController panelController;
  final String? transcript;
  final bool? isSending;
  final ChatProvider chatProvider;

  const SlidingPanel({
    super.key,
    required this.controller,
    required this.panelController,
    this.transcript,
    this.isSending,
    required this.chatProvider,
  });

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
    return GestureDetector(
      onTap: togglePanel,
      child: Center(
        child: !panelController.isPanelOpen
            ? const Icon(Icons.keyboard_arrow_up_outlined)
            : const Icon(Icons.keyboard_arrow_down_outlined),
      ),
    );
  }

  void togglePanel() => panelController.isPanelOpen
      ? panelController.close()
      : panelController.open();

  void _deleteChatMessages(ChatProvider chatProvider) async {
    chatProvider.messages.clear();
    await FirestoreService().deleteChatMessages(chatProvider.chatID);
  }

  Widget buildContent(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                chatProvider.chatID == "" ? "New Chat" : chatProvider.chatID,
                style: Theme.of(context).textTheme.displaySmall,
              ),
              chatProvider.messages.isEmpty
                  ? Container()
                  : Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                  color: Theme.of(context).colorScheme.primary,
                                  spreadRadius: 0),
                            ],
                          ),
                          height: 40,
                          width: 40,
                          child: IconButton(
                            onPressed: () async {
                              chatProvider.setChatId(
                                await FirestoreService().saveChatMessages(
                                    chatProvider.chatID, chatProvider.messages),
                              );
                            },
                            icon: const Icon(
                              Icons.save_outlined,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                        const HorizontalSpace(10),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                  color: Theme.of(context).colorScheme.primary,
                                  spreadRadius: 0),
                            ],
                          ),
                          height: 40,
                          width: 40,
                          child: IconButton(
                            onPressed: () async {
                              chatProvider.chatID == ""
                                  ? chatProvider.messages.clear()
                                  : _deleteChatMessages(chatProvider);
                              chatProvider.setChatId("");
                            },
                            icon: const Icon(
                              Icons.delete_outline,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
            ],
          ),
          const VerticalSpace(20),
        ],
      );

  Widget buildChat(BuildContext context) {
    final chatScrollController = ScrollController();
    return Column(
      children: [
        chatProvider.messages.isEmpty
            ? const Text(
                'Start a new chat with the avatar to see the conversation here.',
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 15,
                    fontWeight: FontWeight.w400),
              )
            : SingleChildScrollView(
                child: Column(
                  children: [
                    ListView.builder(
                      shrinkWrap: true,
                      itemCount: chatProvider.messages.length,
                      itemBuilder: (BuildContext context, int index) {
                        var chat = chatProvider.messages[index];
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
