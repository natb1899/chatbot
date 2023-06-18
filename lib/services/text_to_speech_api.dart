import 'dart:convert';
import 'dart:io';
import 'package:chatbot/screens/speech_screen.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

Future<File> fetchAndPlayWavFile(String? answerVariable, bool isMan) async {
  //AudioPlayer audioPlayer;

  String answer = answerVariable ?? '';

  String formattedAnswer = answer.replaceAll('\n', '');

  final url = Uri.parse('http://192.168.137.1:5001/synthesize');

  final response = await http.post(
    url,
    headers: {'Content-Type': 'application/json'},
    body: '{"text": "$formattedAnswer", "isMan": $isMan}',
  );

  late String filePath = "";

  Directory? appExternalDirectory = await getExternalStorageDirectory();
  if (appExternalDirectory != null) {
    filePath = '${appExternalDirectory.path}/file.wav';
  } else {
    //
  }

  // Specify the desired file path
  File file = File(filePath);
  await file.writeAsBytes(response.bodyBytes);

  return file;
}

Future<Map<String, dynamic>?> getTTSData(
    String? answerVariable, bool isMan) async {
  String answer = answerVariable ?? '';

  String formattedAnswer = answer.replaceAll('\n', '');

  final url = Uri.parse('http://192.168.137.1:5001/synthesize');

  try {
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: '{"text": "$formattedAnswer", "isMan": $isMan}',
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
      } else {
        //
      }

      // Specify the desired file path
      File file = File(filePath);
      await file.writeAsBytes(audioBytes);

      List<VisemeEvent> convertedList = dataArray.map<VisemeEvent>((item) {
        return VisemeEvent(item[0] as double, item[1] as int);
      }).toList();

      return {
        'file': file,
        'convertedList': convertedList,
      };

      // Handle the file and data as needed
      // For example, save the file locally or display the data
    } else {
      print('Request failed with status: ${response.statusCode}');
      return null;
    }
  } catch (e) {
    print('Error: $e');
    return null;
  }
}
