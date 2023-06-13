import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:chatbot/services/endpoints.dart';
import 'package:chatbot/services/speech_to_text_api.dart';

void main() {
  test('Test getSTTData', () async {
    const path = 'test/assets/helloworld.m4a';
    const transcript = 'Hello world.';

    // Set up a mock HTTP client for testing
    final client = MockClient(
      (request) async {
        final url = request.url.toString();
        if (url == '${Endpoints.baseUrl}${Endpoints.speechToText}') {
          // Simulate a successful response
          return http.Response('{"transcript":"$transcript"}', 200);
        } else {
          // Simulate an error response
          return http.Response('Request failed', 400);
        }
      },
    );

    // Test when the file is in cache
    final result = await getSTTData(path);
    expect(result, equals(transcript));

    // Test when the file is not in cache
    const nonExistingPath = 'non/existing/file.m4a';
    final nonExistingResult = await getSTTData(nonExistingPath);
    expect(nonExistingResult, isNull);
  });
}
