import 'dart:convert';
import 'dart:io';

import 'package:chatbot/core/error/exception.dart';
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
  Future<AnswerModel> getAnswer(List<ChatMessage> messages, String model);
  Future<SpeechModel> getSpeech(String answer, bool isMan, String language);
}

class ApiRemoteDataSourceImpl implements ApiRemoteDataSource {
  final http.Client httpClient;
  ApiRemoteDataSourceImpl(this.httpClient);

  @override
  Future<TranscriptionModel> getTranscription(String path) async {
    late final Uri url;
    late final File file;

    // Checks if the file is present in the cache
    if (await _isFileInCache(path)) {
      // Assigns the file from the given path
      file = File(path);
    }

    // Parses the API URL using the 'whisper' endpoint
    url = Uri.parse(Endpoints.apiURL("whisper"));

    try {
      // Uploads the file and sets a timeout of 10 seconds
      final response = await _uploadFile(url, file, "audio.m4a")
          .timeout(const Duration(seconds: 10));

      // Throws a ServerException if the response status code is not 200
      if (response.statusCode != 200) {
        throw ServerException();
      }

      // Converts the response stream to a string
      final responseBody = await response.stream.bytesToString();

      // Parses the JSON response and returns a TranscriptionModel object
      return TranscriptionModel.fromJson(json.decode(responseBody));
    } catch (e) {
      // Throws a TimeoutException if an error occurs during the upload or timeout
      throw TimeoutException();
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

  // This method is used to retrieve an answer from the server by sending a list of ChatMessage objects and a model name.
  @override
  Future<AnswerModel> getAnswer(
      List<ChatMessage> messages, String model) async {
    // Create the URL for the API endpoint using the provided model name.
    final url = Uri.parse(Endpoints.apiURL("chatgpt"));

    try {
      // set a timeout of 10 seconds for the response.
      final response = await _sendMessageList(url, messages, model)
          .timeout(const Duration(seconds: 10));

      // If the server responds with a status code of 200 (OK),
      // decode the response body (assuming it's in UTF-8) and convert it into an AnswerModel object.
      if (response.statusCode == 200) {
        final responseBody = utf8.decode(response.bodyBytes);
        return AnswerModel.fromJson(json.decode(responseBody));
      } else {
        // If the server responds with an error status code,
        // throw a ServerException to indicate a server-side issue.
        throw ServerException();
      }
    } catch (e) {
      // If the server takes more than 10 seconds to respond, throw a TimeoutException.
      throw TimeoutException();
    }
  }

  Future<http.Response> _sendMessageList(
      Uri url, List<ChatMessage> messages, String model) async {
    final List<Map<String, String>> jsonData =
        messages.map((item) => item.toJson()).toList();

    final response = await httpClient.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'model': model,
        'messages': jsonData,
      }),
    );
    return response;
  }

  @override
  Future<SpeechModel> getSpeech(
      String answer, bool isMan, String language) async {
    final url = Uri.parse(Endpoints.apiURL("azure"));

    final response = await httpClient.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: '{"text": "$answer", "isMan": $isMan, "language": "$language"}',
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
      throw ServerException();
    }
  }
}
