import 'package:chatbot/data/datasources/api_remote_datasource.dart';
import 'package:chatbot/data/repositories/api_repository_impl.dart';
import 'package:chatbot/domain/entities/viseme_entity.dart';
import 'package:chatbot/domain/usecases/get_speech.dart';
import 'package:chatbot/presentation/provider/block_provider.dart';
import 'package:chatbot/presentation/provider/chat_provider.dart';
import 'package:chatbot/presentation/provider/language_provider.dart';
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
  bool _isVolumeOn = true;
  late bool isMan;
  late String gptModel;
  late String language;

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
    language = Provider.of<LanguageProvider>(context).language;

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
              SizedBox(
                width: 400.0,
                height: 400.0,
                child: rive.RiveAnimation.asset('assets/animations/avatars.riv',
                    artboard: isMan ? "Man" : "Woman",
                    onInit: _onRiveInit,
                    fit: BoxFit.fitHeight),
              ),
              const Text(
                "Image by Freepik",
                style: TextStyle(color: Colors.black, fontSize: 4),
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
              ),
              IconButton(
                onPressed: _toggleVolume,
                icon: Icon(_isVolumeOn ? Icons.volume_up : Icons.volume_off),
              ),
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

  void _toggleVolume() {
    if (_isVolumeOn) {
      _audioPlayer.setVolume(0);
    } else {
      _audioPlayer.setVolume(1);
    }
    setState(
      () {
        _isVolumeOn = !_isVolumeOn;
      },
    );
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
      setState(
        () {
          _boolListeningInput?.value = false;
        },
      );
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

  // This method is responsible for playing an audio response given an answer.
  Future<void> _playAudio(answer) async {
    // Create an instance of GetSpeech with the appropriate API repository.
    final GetSpeech getSpeech = GetSpeech(
      ApiRepositoryImpl(
        ApiRemoteDataSourceImpl(http.Client()),
      ),
    );

    try {
      // Request speech transcription using the GetSpeech service.
      var transcription = await getSpeech.execute(answer, isMan, language);

      late File file;

      // Process the response from GetSpeech.
      transcription.fold(
        (failure) {
          // In case of failure, log the error if in debug mode.
          if (kDebugMode) {
            print('$failure');
          }
        },
        (speechEntity) {
          // In case of success, set the file and viseme events from the speechEntity.
          file = speechEntity.file;
          visemeEvents = speechEntity.visemes;
        },
      );

      // Create an instance of AudioPlayer to play the audio.
      _audioPlayer = AudioPlayer();

      // Set the file path and load the audio file.
      await _audioPlayer.setFilePath(file.path);
      await _audioPlayer.load();

      _createVisemes();

      // Update the UI to indicate that thinking is complete.
      setState(
        () {
          _boolThinkingInput?.value = false;
        },
      );

      // Play the audio and handle the completion event to unblock the app.
      await _audioPlayer.play().then(
        (value) {
          blockingProvider.isBlocked = false; // Unblock the app.
        },
      );

      // Dispose of the audio player after playing.
      _audioPlayer.dispose();
    } catch (e) {
      // In case of any exceptions, handle the error and unblock the app.
      blockingProvider.isBlocked = false;
      // Update the UI to indicate that listening is stopped.
      setState(
        () {
          _boolListeningInput?.value = false;
        },
      );
      // Update the UI to indicate that thinking is complete.
      setState(
        () {
          _boolThinkingInput?.value = false;
        },
      );
      // Show an error dialog with the exception details.
      _showErrorDialog(e.toString());
    }
  }

  // This method is used to create visemes based on the audio playback time.
  void _createVisemes() {
    // Whenever the audio position changes, this callback will be triggered.
    _audioPlayer.positionStream.listen(
      (event) {
        // Retrieve the audio time in milliseconds from the event.
        double audioTime = event.inMilliseconds.toDouble();
        // Set the state to update the visual representation of the viseme.
        setState(
          () {
            // Call the getVisemeId method to determine the appropriate visemeId
            // based on the current audio time, and update the corresponding value.
            _numberVisemesInput?.value = getVisemeId(audioTime).toDouble();
          },
        );
      },
    );
  }

  // This method retrieves the visemeId corresponding to the given audioTime.
  int getVisemeId(double audioTime) {
    for (int i = visemeEvents.length - 1; i >= 0; i--) {
      final visemeEvent = visemeEvents[i];
      // Check if the audio offset of the current visemeEvent is less than or equal to the given audioTime.
      if (visemeEvent.audioOffset <= audioTime) {
        // If true, return the corresponding visemeId for the current audioTime.
        return visemeEvent.visemeId;
      }
    }
    // If no appropriate visemeId is found for the given audioTime, return 0 as a default value.
    return 0;
  }

  /// Callback function called when the Rive animation is initialized and the [artboard] is ready.
  void _onRiveInit(rive.Artboard artboard) {
    // Create a StateMachineController using the 'State' state machine in the provided [artboard].
    final controller =
        rive.StateMachineController.fromArtboard(artboard, 'State');

    // Add the created controller to the [artboard] so that it can control the animation.
    artboard.addController(controller!);

    // Find and assign the 'viseme' input of type double from the controller to the [_numberVisemesInput] variable.
    _numberVisemesInput =
        controller.findInput<double>('viseme') as rive.SMINumber;

    // Find and assign the 'thinking' input of type bool from the controller to the [_boolThinkingInput] variable.
    _boolThinkingInput = controller.findInput<bool>('thinking') as rive.SMIBool;

    // Find and assign the 'listening' input of type bool from the controller to the [_boolListeningInput] variable.
    _boolListeningInput =
        controller.findInput<bool>('listening') as rive.SMIBool;
  }
}
