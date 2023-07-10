import 'package:chatbot/injector.dart';
import 'package:chatbot/presentation/screens/profile_screen/profile_screen.dart';
import 'package:chatbot/presentation/screens/settings_screen/settings_screen.dart';
import 'package:chatbot/presentation/screens/tree_screen/tree_screen.dart';
import 'package:chatbot/theme/light_theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(
    const Injector(
      router: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: lightTheme,
      //darkTheme: darkTheme,
      home: const Scaffold(
        body: Tree(),
      ),
      routes: {
        '/settings': (_) => const SettingsScreen(),
        '/profile': (_) => const ProfileScreen(),
      },
    );
  }
}
