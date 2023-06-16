import 'package:chatbot/screens/speech_screen.dart';
import 'package:chatbot/services/auth.dart';
import 'package:chatbot/theme/app_bar_theme.dart';
import 'package:chatbot/utils/helper_widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  //final List<ChatMessage> messages;

  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MyAppBar(title: 'Chatbot Demo'),
      drawer: DrawerTheme(
        context: context,
      ),
      body: const Center(
        child: SpeechScreen(),
      ),
    );
  }
}

class DrawerTheme extends StatelessWidget {
  final BuildContext context;

  final User? user = Auth().currentUser;

  Future<void> signOut(BuildContext context) async {
    await Auth().signOut(context);
  }

  DrawerTheme({
    super.key,
    required this.context,
  });

  @override
  Widget build(context) {
    return Drawer(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              children: [
                const VerticalSpace(75),
                Text("Chats", style: Theme.of(context).textTheme.displaySmall),
                const VerticalSpace(50),
                /*StreamBuilder<List<String>>(
                  stream: FirestoreService().getChatsStream(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      // While waiting for data to load
                      return const CircularProgressIndicator();
                    } else if (snapshot.hasError) {
                      // If an error occurred
                      return Text('Error: ${snapshot.error}');
                    } else {
                      // If data has been loaded successfully
                      List<String> dataList = snapshot.data ?? [];
                      return ListView.builder(
                        padding: const EdgeInsets.only(left: 20, right: 20),
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
                                List<ChatMessage> messages =
                                    await FirestoreService()
                                        .getListFromFirestore(chatId: chatId);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => HomeScreen(
                                      messages: messages,
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      );
                    }
                  },
                ),*/
              ],
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
