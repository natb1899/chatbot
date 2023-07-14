import 'dart:convert';

import 'package:chatbot/core/error/exception.dart';
import 'package:chatbot/data/models/answer_model.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_test/flutter_test.dart';
import 'package:http/testing.dart';

import 'package:chatbot/data/datasources/api_remote_datasource.dart';
import 'package:chatbot/data/models/transcription_model.dart';

void main() {
  group(
    'fetchSTT',
    () {
      test(
        'returns an TranscriptionModel if the http call completes successfully',
        () async {
          final client = MockClient((request) async {
            return http.Response('{"text": "Hello World."}', 200);
          });

          final apiRemoteDataSourceImpl = ApiRemoteDataSourceImpl(client);

          const path = "test/assets/helloworld.m4a";

          expect(await apiRemoteDataSourceImpl.getTranscription(path),
              isA<TranscriptionModel>());
        },
      );

      test(
        'throws an timeout_exception if the http call completes with an error',
        () {
          final client = MockClient((request) async {
            return http.Response('{"error": "server-error"}', 500);
          });

          final apiRemoteDataSourceImpl = ApiRemoteDataSourceImpl(client);

          const path = "test/assets/helloworld.m4a";

          expect(() => apiRemoteDataSourceImpl.getTranscription(path),
              throwsA(isA<TimeoutException>()));
        },
      );
    },
  );

  group(
    'fetchChatGPT',
    () {
      test(
        'returns an TranscriptionModel if the http call completes successfully',
        () async {
          final client = MockClient((request) async {
            return http.Response(
              json.encode(
                {
                  'choices': [
                    {
                      'message': {'content': 'Hello!'}
                    }
                  ]
                },
              ),
              200,
            );
          });

          final apiRemoteDataSourceImpl = ApiRemoteDataSourceImpl(client);

          expect(await apiRemoteDataSourceImpl.getAnswer([], "gpt-4"),
              isA<AnswerModel>());
        },
      );

      test(
        'throws an timeout_exception if the http call completes with an error',
        () {
          final client = MockClient((request) async {
            return http.Response('{"error": "server-error"}', 500);
          });

          final apiRemoteDataSourceImpl = ApiRemoteDataSourceImpl(client);

          expect(() => apiRemoteDataSourceImpl.getAnswer([], "gpt-4"),
              throwsA(isA<TimeoutException>()));
        },
      );
    },
  );
}
