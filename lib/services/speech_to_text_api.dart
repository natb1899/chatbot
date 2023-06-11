import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http_parser/http_parser.dart';
import 'package:http/http.dart' as http;

import 'package:chatbot/services/endpoints.dart';
import 'package:chatbot/utils/check_file_is_in_cache.dart';

Future<String?> getSTTData(String path) async {
  if (await isFileInCache(path)) {
    final url = Uri.parse('${Endpoints.baseUrl}${Endpoints.speechToText}');
    final file = File(path);

    final response = await uploadFile(url, file, "audio.m4a");

    if (response.statusCode == 200) {
      final responseBody = await response.stream.bytesToString();
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
  } else {
    if (kDebugMode) {
      print("FILE DOES NOT EXIST");
    }
    return null;
  }
}

Future<http.StreamedResponse> uploadFile(
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
  return request.send();
}
