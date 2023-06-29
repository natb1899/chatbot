import 'dart:convert';
import 'dart:io';

import 'package:chatbot/data/models/answer_model.dart';
import 'package:chatbot/data/models/speech_model.dart';
import 'package:chatbot/data/models/transcription_model.dart';
import 'package:chatbot/domain/entities/chat_message_entity.dart';
import 'package:chatbot/data/constants.dart';
import 'package:chatbot/domain/entities/viseme_entity.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:path_provider/path_provider.dart';

abstract class ApiRemoteDataSource {
  Future<TranscriptionModel> getTranscription(String path);
  Future<AnswerModel> getAnswer(List<ChatMessage> messages);
  Future<SpeechModel> getSpeech(String answer, bool isMan);
}

class ApiRemoteDataSourceImpl implements ApiRemoteDataSource {
  final http.Client httpClient;
  ApiRemoteDataSourceImpl(this.httpClient);

  @override
  Future<TranscriptionModel> getTranscription(String path) async {
    late final Uri url;
    late final File file;

    if (await _isFileInCache(path)) {
      file = File(path);
    }

    url = Uri.parse(Endpoints.apiURL("whisper"));

    final response = await _uploadFile(url, file, "audio.m4a")
        .timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final responseBody = await response.stream.bytesToString();
      return TranscriptionModel.fromJson(json.decode(responseBody));
    } else {
      throw Exception('Failed to load transcription');
    }
  }

  Future<http.StreamedResponse> _uploadFile(
      Uri url, File file, String filename) async {
    final request = http.MultipartRequest('POST', url);
    request.files.add(
      await http.MultipartFile.fromPath(
        'file',
        file.path,
        filename: filename,
        contentType: MediaType('audio', 'm4a'),
      ),
    );
    return httpClient.send(request);
  }

  Future<bool> _isFileInCache(String filePath) async {
    final file = File(filePath);
    return file.exists();
  }

  @override
  Future<AnswerModel> getAnswer(List<ChatMessage> messages) async {
    final url = Uri.parse(Endpoints.apiURL("chatgpt"));

    final response = await _sendMessageList(url, messages);

    if (response.statusCode == 200) {
      final responseBody = utf8.decode(response.bodyBytes);
      return AnswerModel.fromJson(json.decode(responseBody));
    } else {
      throw Exception('Failed to load transcription');
    }
  }

  Future<http.Response> _sendMessageList(
      Uri url, List<ChatMessage> messages) async {
    final List<Map<String, String>> jsonData =
        messages.map((item) => item.toJson()).toList();

    final response = await httpClient.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(jsonData),
    );
    return response;
  }

  @override
  Future<SpeechModel> getSpeech(String answer, bool isMan) async {
    final url = Uri.parse(Endpoints.apiURL("synthesize"));

    final response = await httpClient.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: '{"text": "$answer", "isMan": $isMan}',
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      // Access the base64 encoded audio and data array
      final audioBase64 = data['audio_file'];
      final dataArray = data['viseme_data'];

      // Decode base64 to audio bytes
      final audioBytes = base64Decode(audioBase64);

      late String filePath = "";

      Directory? appExternalDirectory = await getExternalStorageDirectory();

      if (appExternalDirectory != null) {
        filePath = '${appExternalDirectory.path}/file.wav';
      }

      // Specify the desired file path
      File file = File(filePath);
      await file.writeAsBytes(audioBytes);

      List<Viseme> convertedList = dataArray.map<Viseme>(
        (item) {
          return Viseme(item[0] as double, item[1] as int);
        },
      ).toList();

      return SpeechModel.fromJson(
        {
          'file': file,
          'visemes': convertedList,
        },
      );
    } else {
      throw Exception('Failed to load speech');
    }
  }
}
