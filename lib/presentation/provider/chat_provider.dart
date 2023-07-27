import 'package:chatbot/data/datasources/firebase/firestore.dart';
import 'package:chatbot/domain/entities/chat_message_entity.dart';
import 'package:chatbot/domain/usecases/get_answer.dart';
import 'package:chatbot/domain/usecases/get_transcription.dart';
import 'package:flutter/foundation.dart';

import 'package:chatbot/data/datasources/api_remote_datasource.dart';
import 'package:chatbot/data/repositories/api_repository_impl.dart';
import 'package:http/http.dart' as http;

class ChatProvider extends ChangeNotifier {
  static ChatProvider? _instance;

  factory ChatProvider() {
    _instance ??= ChatProvider._internal();
    return _instance!;
  }

  ChatProvider._internal();

  final GetTranscription getTranscription = GetTranscription(
    ApiRepositoryImpl(
      ApiRemoteDataSourceImpl(http.Client()),
    ),
  );

  final GetAnswer getAnswer = GetAnswer(
    ApiRepositoryImpl(
      ApiRemoteDataSourceImpl(http.Client()),
    ),
  );

  List<ChatMessage> _messages = [];

  List<ChatMessage> get messages => _messages;

  String chatID = "";

  Future<void> getTranscriptionSTT(String path) async {
    var transcription = await getTranscription.execute(path);

    transcription.fold(
      (failure) {
        if (kDebugMode) {
          print('$failure');
        }
      },
      (transcriptionEntity) {
        addMessage(
          ChatMessage(
            transcript: transcriptionEntity.transcript,
            type: ChatType.user,
          ),
        );
      },
    );
    notifyListeners();
  }

  Future<void> getChatGPT(String gptModel) async {
    var answer = await getAnswer.execute(messages, gptModel);

    answer.fold(
      (failure) {
        if (kDebugMode) {
          print('$failure');
        }
      },
      (answerEntity) {
        addMessage(
          ChatMessage(
            transcript: answerEntity.answer,
            type: ChatType.assistent,
          ),
        );
      },
    );
    notifyListeners();
  }

  void addMessage(ChatMessage message) async {
    _messages.add(
      message,
    );
    setChatId(
      await FirestoreService().saveChatMessages(chatID, messages),
    );
  }

  void setChatMessages(List<ChatMessage> newMessages) {
    _messages = newMessages;
    notifyListeners();
  }

  void setChatId(String chatId) {
    chatID = chatId;
    notifyListeners();
  }
}
