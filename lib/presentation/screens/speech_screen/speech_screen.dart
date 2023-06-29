import 'package:chatbot/data/datasources/api_remote_datasource.dart';
import 'package:chatbot/data/repositories/api_repository_impl.dart';
import 'package:chatbot/domain/entities/viseme_entity.dart';
import 'package:chatbot/domain/usecases/get_speech.dart';
import 'package:chatbot/presentation/provider/chat_provider.dart';
import 'package:chatbot/presentation/provider/sending_provider.dart';
import 'package:chatbot/presentation/screens/speech_screen/widgets/record_control_widget.dart';
import 'package:chatbot/presentation/screens/speech_screen/widgets/sliding_up_panel_widget.dart';
import 'package:chatbot/presentation/screens/speech_screen/widgets/typing_animation.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';
import 'package:chatbot/presentation/provider/gender_provider.dart';

import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';
import 'package:record/record.dart';
import 'package:rive/rive.dart' as rive;
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:http/http.dart' as http;

class SpeechScreen extends StatefulWidget {
  const SpeechScreen({Key? key}) : super(key: key);

  @override
  State<SpeechScreen> createState() => _SpeechScreenState();
}

class _SpeechScreenState extends State<SpeechScreen> {
  late Record _audioRecorder;
  late AudioPlayer _audioPlayer;
  String? _transcript;
  late bool isMan;

  late PanelController _panelController;
  late SendingProvider sendingProvider;
  late ChatProvider chatProvider;

  List<Viseme> visemeEvents = [];
  rive.SMIInput<double>? _numberExampleInput;

  @override
  void initState() {
    _audioRecorder = Record();
    _audioPlayer = AudioPlayer();
    _panelController = PanelController();
    if (kDebugMode) {
      print("object");
      print(_transcript);
    }
    super.initState();
  }

  @override
  void dispose() {
    _audioRecorder.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final panelHeightOpen = MediaQuery.of(context).size.height * 0.85;
    final screenWidth = MediaQuery.of(context).size.width;

    isMan = Provider.of<GenderProvider>(context).isMan;
    chatProvider = Provider.of<ChatProvider>(context);
    sendingProvider = Provider.of<SendingProvider>(context);

    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerTop,
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          RecordControl(start: _start, stop: _stop),
        ],
      ),
      body: SlidingUpPanel(
        controller: _panelController,
        minHeight: 120,
        maxHeight: panelHeightOpen,
        parallaxEnabled: true,
        parallaxOffset: .1,
        panelBuilder: (controller) => SlidingPanel(
          controller: controller,
          panelController: _panelController,
          transcript: _transcript,
          chatProvider: chatProvider,
          isSending: sendingProvider.isSending,
          messages: chatProvider.messages,
        ),
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(10),
        ),
        body: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          margin: EdgeInsets.zero,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 50, bottom: 20),
                child: Container(
                  width: 300.0,
                  height: 300.0,
                  decoration: BoxDecoration(
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.circular(10.0),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.primary,
                      width: 2.0,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(0.0),
                    child: rive.RiveAnimation.asset(
                        'assets/animations/character-animation.riv',
                        artboard: isMan ? "Man" : "Woman",
                        onInit: _onRiveInit,
                        fit: BoxFit.fitHeight),
                  ),
                ),
              ),
              sendingProvider.isSending
                  ? const TypingAnimaton(vertical: 15.0, horizontal: 0.0)
                  : Padding(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      child: SizedBox(
                        width: screenWidth * 0.75,
                        child: Text(
                          "Tap and hold the button to record your message",
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.displaySmall,
                        ),
                      ),
                    )
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _start() async {
    try {
      if (await _audioRecorder.hasPermission()) {
        final isSupported = await _audioRecorder.isEncoderSupported(
          AudioEncoder.aacLc,
        );

        if (kDebugMode) {
          print('${AudioEncoder.aacLc.name} supported: $isSupported');
        }

        sendingProvider.isSending = true;

        await _audioRecorder.start();
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  Future<void> _stop() async {
    final path = await _audioRecorder.stop();

    if (path != null) {
      try {
        await chatProvider.getTranscriptionSTT(path);
        await chatProvider.getChatGPT();
        sendingProvider.isSending = false;
        _playAudio(chatProvider.messages.last.transcript);
      } catch (e) {
        if (kDebugMode) {
          print(e);
        }
        _showErrorDialog("Error");
      }
    }
  }

  void _showErrorDialog(String? text) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Center(child: Text(text!)),
          actions: <Widget>[
            Center(
              child: ElevatedButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _playAudio(answer) async {
    final GetSpeech getSpeech = GetSpeech(
      ApiRepositoryImpl(
        ApiRemoteDataSourceImpl(http.Client()),
      ),
    );

    try {
      var transcription = await getSpeech.execute(answer, isMan);

      late File file;

      transcription.fold(
        (failure) {
          print('Failed to get transcription: $failure');
        },
        (speechEntity) {
          file = speechEntity.file;
          visemeEvents = speechEntity.visemes;
        },
      );

      await _audioPlayer.setFilePath(file.path);
      await _audioPlayer.load();

      _listenToAudio();

      await _audioPlayer.play();
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  void _listenToAudio() {
    _audioPlayer.positionStream.listen(
      (event) {
        double audioTime = event.inMilliseconds.toDouble();
        setState(
          () {
            _numberExampleInput?.value = getVisemeId(audioTime).toDouble();
          },
        );
      },
    );
  }

  int getVisemeId(double audioTime) {
    for (int i = visemeEvents.length - 1; i >= 0; i--) {
      final visemeEvent = visemeEvents[i];
      if (visemeEvent.audioOffset <= audioTime) {
        return visemeEvent.visemeId;
      }
    }
    return 0;
  }

  void _onRiveInit(rive.Artboard artboard) {
    final controller =
        rive.StateMachineController.fromArtboard(artboard, 'State');
    artboard.addController(controller!);
    _numberExampleInput =
        controller.findInput<double>('viseme') as rive.SMINumber;
  }
}
