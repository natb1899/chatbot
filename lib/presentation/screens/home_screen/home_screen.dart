import 'package:chatbot/presentation/screens/home_screen/widgets/drawer_widget.dart';
import 'package:chatbot/presentation/screens/speech_screen/speech_screen.dart';
import 'package:chatbot/theme/app_bar_theme.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MyAppBar(title: 'Chatbot Demo'),
      drawer: CustomDrawer(
        context: context,
      ),
      body: const Center(
        child: SpeechScreen(),
      ),
    );
  }
}
