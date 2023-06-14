import 'package:chatbot/screens/tree_screen.dart';
import 'package:chatbot/theme/light_theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter layout demo',
      theme: lightTheme,
      //darkTheme: darkTheme,
      home: const Scaffold(
        body: Tree(),
      ),
    );
  }
}
