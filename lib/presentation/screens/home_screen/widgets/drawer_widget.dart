import 'package:chatbot/domain/entities/chat_message_entity.dart';
import 'package:chatbot/data/datasources/firebase/firestore.dart';
import 'package:chatbot/presentation/provider/chat_provider.dart';
import 'package:chatbot/utils/helper_widgets.dart';
import 'package:flutter/material.dart';

class CustomDrawer extends StatefulWidget {
  final BuildContext context;

  const CustomDrawer({super.key, required this.context});

  @override
  State<CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  @override
  Widget build(context) {
    ChatProvider chatProvider = ChatProvider();

    return Drawer(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 20, right: 20),
              child: Column(
                children: [
                  const VerticalSpace(75),
                  Text("Chats",
                      style: Theme.of(context).textTheme.displaySmall),
                  const VerticalSpace(50),
                  ListTile(
                    leading: const Icon(Icons.chat_bubble_outline),
                    title: const Text("New Chat"),
                    onTap: () async {
                      chatProvider.setChatId("");
                      chatProvider.setChatMessages([]);
                    },
                  ),
                  StreamBuilder<List<String>>(
                    stream: FirestoreService().getAllChats(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        // While waiting for data to load
                        return const CircularProgressIndicator();
                      } else if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      } else {
                        List<String> dataList = snapshot.data ?? [];
                        return ListView.builder(
                          shrinkWrap: true,
                          itemCount: dataList.length,
                          itemBuilder: (context, index) {
                            String chatId = dataList[index];
                            return Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              child: ListTile(
                                leading: const Icon(Icons.chat_bubble_outline),
                                title: Text(chatId),
                                onTap: () async {
                                  chatProvider.setChatId(chatId);
                                  List<ChatMessage> messages =
                                      await FirestoreService()
                                          .getAllChatMessages(chatId: chatId);
                                  chatProvider.setChatMessages(messages);
                                },
                              ),
                            );
                          },
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.settings_outlined),
            title: const Text('Settings'),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(0.0),
            ),
            onTap: () {
              Navigator.pushNamed(context, '/settings');
            },
          ),
        ],
      ),
    );
  }
}
