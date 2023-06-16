import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

Future<File> fetchAndPlayWavFile(String? answerVariable, bool isMan) async {
  //AudioPlayer audioPlayer;

  String answer = answerVariable ?? '';

  String formattedAnswer = answer.replaceAll('\n', '');

  print("TEST");
  print(isMan);

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
