import 'dart:convert';

import 'package:chatbot/model/chat_message.dart';
import 'package:chatbot/services/endpoints.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ApiChatGPT {
  sendMessageGPT() {
    return "The ChatGPT API is not yet implemented.";
  }

  Future<String?> getGPTData(List<ChatMessage> messages) async {
    final url = Uri.parse('${Endpoints.baseUrl}${Endpoints.chatGpt}');

    final response = await sendMessageList(url, messages);

    if (response.statusCode == 200) {
      final responseBody = utf8.decode(response.bodyBytes);
      final jsonResponse = jsonDecode(responseBody);

      final transcript = jsonResponse;

      if (kDebugMode) {
        print(transcript);
      }

      return transcript;
    } else {
      // Handle the error
      if (kDebugMode) {
        print('Request failed with status: ${response.statusCode}.');
      }
      return null;
    }
  }

  Future<http.Response> sendMessageList(
      Uri url, List<ChatMessage> messages) async {
    final List<Map<String, String>> jsonData =
        messages.map((item) => item.toJson()).toList();

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(jsonData),
    );
    return response;
  }

  Future<http.Response> sendMessage(Uri url, String message) async {
    final response = await http.post(
      url,
      body: {'message': message},
    );
    return response;
  }

  /**
   * Diese Methode ist für die Streaming API gedacht; Vielleicht für später um User Experience zu verbessern oder 
   * vielleicht ist diese Streaming API schneller als die normale API;
   * 
   *   Stream<String> getEventStream() async* {
        final url = Uri.parse('http://192.168.137.1:5001/chatgpt2');
        final request = http.Request('GET', url);

        // Set the request headers
        request.headers['Accept'] = 'text/event-stream';

        final response = await request.send();
        final stream = response.stream.transform(utf8.decoder);

        await for (final chunk in stream) {
          final eventData = chunk.replaceAll("\n", "");
          if (eventData.isNotEmpty) {
            final trimmedEvent = eventData;
            yield trimmedEvent;
          }
        }
      }
   */
}
