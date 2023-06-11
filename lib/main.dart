import 'package:chatbot/screens/settings_screen.dart';
import 'package:chatbot/screens/speech_screen.dart';
import 'package:chatbot/theme/app_bar_theme.dart';
import 'package:chatbot/theme/light_theme.dart';
import 'package:chatbot/utils/helper_widgets.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter layout demo',
      theme: lightTheme,
      //darkTheme: darkTheme,
      home: Scaffold(
        appBar: const MyAppBar(title: 'Chatbot Demo'),
        drawer: DrawerTheme(
          context: context,
        ),
        body: Center(
          child: SpeechScreen(
            onStop: (path) {
              if (kDebugMode) print('Recorded file path: $path');
            },
          ),
        ),
      ),
    );
  }
}

class DrawerTheme extends StatelessWidget {
  final BuildContext context;

  const DrawerTheme({
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
            child: ListView(
              padding: const EdgeInsets.only(top: 50, left: 20, right: 20),
              shrinkWrap: true,
              children: [
                const VerticalSpace(25),
                Text("Chats", style: Theme.of(context).textTheme.displaySmall),
                const VerticalSpace(50),
                Container(
                  margin: const EdgeInsets.only(bottom: 15),
                  child: const ListTile(
                    leading: Icon(
                      Icons.messenger_outline,
                      size: 20,
                    ),
                    title: Text('Chat'),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(bottom: 15),
                  child: const ListTile(
                    leading: Icon(
                      Icons.messenger_outline,
                      size: 20,
                    ),
                    title: Text('Chat'),
                  ),
                ),
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
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
    );
  }
}
