import 'package:chatbot/data/datasources/api_remote_datasource.dart';
import 'package:chatbot/data/repositories/api_repository_impl.dart';
import 'package:chatbot/domain/entities/viseme_entity.dart';
import 'package:chatbot/domain/usecases/get_speech.dart';
import 'package:chatbot/presentation/provider/block_provider.dart';
import 'package:chatbot/presentation/provider/chat_provider.dart';
import 'package:chatbot/presentation/provider/model_provider.dart';
import 'package:chatbot/presentation/provider/recording_provider.dart';
import 'package:chatbot/presentation/screens/speech_screen/widgets/record_control_widget.dart';
import 'package:chatbot/presentation/screens/speech_screen/widgets/sliding_up_panel_widget.dart';
import 'package:chatbot/utils/helper_widgets.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';
import 'package:chatbot/presentation/provider/gender_provider.dart';

import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:permission_handler/permission_handler.dart';
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
  late String gptModel;

  late PanelController _panelController;
  late RecordingProvider recordingProvider;
  late BlockProvider blockingProvider;
  late ChatProvider chatProvider;

  List<Viseme> visemeEvents = [];
  rive.SMIInput<double>? _numberVisemesInput;
  rive.SMIInput<bool>? _boolThinkingInput;
  rive.SMIInput<bool>? _boolListeningInput;

  @override
  void initState() {
    _audioRecorder = Record();
    _panelController = PanelController();
    checkAudioPermission();
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
    gptModel = Provider.of<ModelProvider>(context).model;

    chatProvider = Provider.of<ChatProvider>(context);
    recordingProvider = Provider.of<RecordingProvider>(context);
    blockingProvider = Provider.of<BlockProvider>(context);

    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerTop,
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          RecordControl(
            start: _start,
            stop: _stop,
            isBlocked: blockingProvider.isBlocked,
            isRecording: recordingProvider,
          ),
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
                padding: const EdgeInsets.only(bottom: 5),
                child: SizedBox(
                  width: 400.0,
                  height: 400.0,
                  child: rive.RiveAnimation.asset(
                      'assets/animations/avatars.riv',
                      artboard: isMan ? "Man" : "Woman",
                      onInit: _onRiveInit,
                      fit: BoxFit.fitHeight),
                ),
              ),
              Padding(
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

  // Method to check audio permission asynchronously
  void checkAudioPermission() async {
    // Get the current status of the microphone permission
    var status = await Permission.microphone.status;

    // If the permission is denied, request it
    if (status.isDenied) {
      await Permission.microphone.request();
    }
  }

  // Method to start recording audio
  Future<void> _start() async {
    try {
      // Check if the app has permission to record audio
      if (await _audioRecorder.hasPermission()) {
        setState(
          () {
            _boolListeningInput?.value = recordingProvider.isRecording;
          },
        );
        // Start recording audio
        await _audioRecorder.start();
      } else {
        // Show an error dialog if the permission to record audio is denied
        _showErrorDialog("Permission denied");
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  // Method to stop recording audio
  Future<void> _stop() async {
    // Stop the audio recording and get the file path
    final path = await _audioRecorder.stop();

    setState(
      () {
        _boolListeningInput?.value = recordingProvider.isRecording;
      },
    );

    // Set the blocking flag to indicate that the record button is blocked
    blockingProvider.isBlocked = true;

    // If a valid file path is obtained
    if (path != null) {
      try {
        // Update the state by setting a boolean value
        setState(
          () {
            _boolThinkingInput?.value = true;
          },
        );

        // Get the transcription using speech-to-text (STT)
        await chatProvider.getTranscriptionSTT(path);

        // Get the response from ChatGPT using the GPT model
        await chatProvider.getChatGPT(gptModel);

        // Play the audio of the last message's transcript
        _playAudio(chatProvider.messages.last.transcript);
      } catch (e) {
        setState(
          () {
            _boolThinkingInput?.value = false;
          },
        );
        // If an error occurs, unblock the record button and show an error dialog
        blockingProvider.isBlocked = false;
        _showErrorDialog(e.toString());
      }
    }
  }

  void _showErrorDialog(String? text) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.primary,
          title: Center(
            child: Column(
              children: [
                Image.asset(
                  'assets/images/supermeme.png',
                ),
                const VerticalSpace(15),
                Text(text!, style: Theme.of(context).textTheme.bodyMedium),
                text.contains("Permission denied")
                    ? GestureDetector(
                        child: Text(
                          'Click here to open the settings',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        onTap: () {
                          openAppSettings();
                        },
                      )
                    : Container()
              ],
            ),
          ),
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
          if (kDebugMode) {
            print('$failure');
          }
        },
        (speechEntity) {
          file = speechEntity.file;
          visemeEvents = speechEntity.visemes;
        },
      );

      _audioPlayer = AudioPlayer();

      await _audioPlayer.setFilePath(file.path);
      await _audioPlayer.load();

      _listenToAudio();

      setState(
        () {
          _boolThinkingInput?.value = false;
        },
      );

      await _audioPlayer.play().then(
        (value) {
          blockingProvider.isBlocked = false;
        },
      );

      _audioPlayer.dispose();
    } catch (e) {
      setState(
        () {
          _boolThinkingInput?.value = false;
        },
      );
      _showErrorDialog(e.toString());
    }
  }

  void _listenToAudio() {
    _audioPlayer.positionStream.listen(
      (event) {
        double audioTime = event.inMilliseconds.toDouble();
        setState(
          () {
            _numberVisemesInput?.value = getVisemeId(audioTime).toDouble();
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
    _numberVisemesInput =
        controller.findInput<double>('viseme') as rive.SMINumber;
    _boolThinkingInput = controller.findInput<bool>('thinking') as rive.SMIBool;
    _boolListeningInput =
        controller.findInput<bool>('listening') as rive.SMIBool;
  }
}
