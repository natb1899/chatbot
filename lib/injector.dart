import 'package:chatbot/presentation/provider/chat_provider.dart';
import 'package:chatbot/presentation/provider/gender_provider.dart';
import 'package:chatbot/presentation/provider/sending_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Injector extends StatelessWidget {
  final Widget? router;

  const Injector({Key? key, this.router}) : super(key: key);

  @override
  Widget build(BuildContext context) => MultiProvider(
        providers: [
          ChangeNotifierProvider<GenderProvider>(
              create: (_) => GenderProvider()),
          ChangeNotifierProvider<SendingProvider>(
              create: (_) => SendingProvider()),
          ChangeNotifierProvider<ChatProvider>(create: (_) => ChatProvider()),
        ],
        child: router,
      );
}
