import 'package:chatbot/utils/gender_provider.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:chatbot/services/chat_gpt_api.dart';
import 'package:chatbot/services/speech_to_text_api.dart';
import 'package:chatbot/utils/format_number_utils.dart';
import 'package:chatbot/model/chat_message.dart';
import 'package:chatbot/widgets/record_control_widget.dart';
import 'package:chatbot/widgets/sliding_up_panel_widget.dart';
import 'package:chatbot/widgets/typing_animation.dart';

import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';
import 'package:record/record.dart';
import 'package:rive/rive.dart' as rive;
import 'package:sliding_up_panel/sliding_up_panel.dart';

class SpeechScreen extends StatefulWidget {
  //final List<ChatMessage> messages;

  //const SpeechScreen({Key? key, required this.messages}) : super(key: key);

  const SpeechScreen({Key? key}) : super(key: key);

  @override
  State<SpeechScreen> createState() => _SpeechScreenState();
}

class _SpeechScreenState extends State<SpeechScreen> {
  int _recordDuration = 0;
  Timer? _timer;
  late Record _audioRecorder;
  late AudioPlayer _audioPlayer;
  RecordState _recordState = RecordState.stop;
  String? _transcript;
  bool? isSending;
  late bool isMan;

  //only for demo to show the viseme
  int currentVisemeId = 0;

  //SMITrigger? _bump;
  rive.SMIInput<double>? _numberExampleInput;

  List<ChatMessage> messages = [];

  List<VisemeEvent> visemeEvents = [];

  final panelController = PanelController();

  @override
  void initState() {
    _audioRecorder = Record();
    _audioPlayer = AudioPlayer();
    if (kDebugMode) {
      print("object");
      print(_transcript);
    }
    super.initState();
  }

  void _setRecordState(RecordState state) {
    setState(
      () {
        _recordState = state;
      },
    );
  }

  void _showErrorDialog() async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Center(child: Text('Try again')),
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

  Future<void> _start() async {
    try {
      if (await _audioRecorder.hasPermission()) {
        final isSupported = await _audioRecorder.isEncoderSupported(
          AudioEncoder.aacLc,
        );

        if (kDebugMode) {
          print('${AudioEncoder.aacLc.name} supported: $isSupported');
        }

        setState(() {
          isSending = true;
        });

        _setRecordState(RecordState.record);

        await _audioRecorder.start();
        _recordDuration = 0;

        _startTimer();
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  void _onRiveInit(rive.Artboard artboard) {
    final controller =
        rive.StateMachineController.fromArtboard(artboard, 'State');
    artboard.addController(controller!);
    //_bump = controller.findInput<bool>('speak') as SMITrigger;
    _numberExampleInput =
        controller.findInput<double>('viseme') as rive.SMINumber;
  }

  void _listenToAudio() {
    _audioPlayer.positionStream.listen(
      (event) {
        double audioTime = event.inMilliseconds.toDouble();
        setState(
          () {
            _numberExampleInput?.value = getVisemeId(audioTime).toDouble();
            //only for demo to show the viseme
            currentVisemeId = getVisemeId(audioTime);
          },
        );
        //print(currentVisemeId);
      },
    );
  }

  Future<void> _stop() async {
    _timer?.cancel();
    _recordDuration = 0;

    String? answer = "";

    _setRecordState(RecordState.stop);

    final path = await _audioRecorder.stop();

    if (path != null) {
      try {
        final transcript = await getSTTData(path);

        if (transcript == null) {
          setState(() {
            isSending = false;
          });

          _showErrorDialog();

          return;
        }

        setState(
          () {
            messages.add(
              ChatMessage(
                transcript: transcript,
                type: ChatType.user,
              ),
            );
          },
        );

        /// Normale API nicht mit Streaming API
        answer = (await ApiChatGPT().getGPTData(messages))?.trim();

        setState(
          () {
            messages.add(
              ChatMessage(
                transcript: answer,
                type: ChatType.assistent,
              ),
            );
            // i think i don't need this anymore
            //_transcript = transcript;
          },
        );

        //await _audioPlayer.play();
        /**
         * Diese Methode ist für die Streaming API gedacht; Vielleicht für später um User Experience zu verbessern oder 
         * vielleicht ist diese Streaming API schneller als die normale API;
         * 
         *  // Fetch the streaming data*
            setState(
              () {
                messages.add(
                  ChatMessage(
                    transcript: "",
                    type: ChatType.assistent,
                  ),
                );
              },
            );

            final eventStream = ApiChatGPT().getEventStream();
            await for (final eventData in eventStream) {
              setState(
                () {
                  messages.last.transcript =
                      '${messages.last.transcript ?? ''}$eventData';
                },
              );
            }
        */
      } catch (e) {
        // Code to handle error
      } finally {
        setState(() {
          isSending = false;
        });
      }

      File audioFile = await fetchAndPlayWavFile(answer, isMan);
      await _audioPlayer.setFilePath(audioFile.path);
      await _audioPlayer.play();

      // i think i don't need this anymore
      //final transcript = await sendAudioFile(path);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _audioRecorder.dispose();
    super.dispose();
  }

  Widget _buildText() {
    if (_recordState != RecordState.stop) {
      return _buildTimer();
    }
    return const Text("Tap to record");
  }

  Widget _buildTimer() {
    final String minutes = formatNumber(_recordDuration ~/ 60);
    final String seconds = formatNumber(_recordDuration % 60);

    return Text(
      '$minutes : $seconds',
      style: const TextStyle(color: Colors.black),
    );
  }

  void _startTimer() {
    _timer?.cancel();

    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (Timer t) {
        setState(() => _recordDuration++);
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
    // Return a default viseme ID if no matching viseme event is found
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final panelHeightOpen = MediaQuery.of(context).size.height * 0.85;
    final screenWidth = MediaQuery.of(context).size.width;

    isMan = Provider.of<GenderProvider>(context).isMan;

    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerTop,
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          //_buildText(),
          //const SizedBox(height: 16),
          RecordControl(start: _start, stop: _stop),
        ],
      ),
      body: Scaffold(
        body: SlidingUpPanel(
          body: Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            margin: EdgeInsets.zero,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  'Current Viseme ID: $currentVisemeId',
                  style: const TextStyle(fontSize: 20.0),
                ),
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
                      /*Image.asset(
                        'assets/images/chatbot_cartoon.png',
                        fit: BoxFit.cover,
                      )*/
                    ),
                  ),
                ),
                isSending == true
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
          controller: panelController,
          minHeight: 120,
          maxHeight: panelHeightOpen,
          parallaxEnabled: true,
          parallaxOffset: .1,
          panelBuilder: (controller) => SlidingPanel(
            controller: controller,
            panelController: panelController,
            transcript: _transcript,
            isSending: isSending,
            messages: messages,
          ),
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(10),
          ),
        ),
      ),
    );
  }
}

class VisemeEvent {
  final double audioOffset;
  final int visemeId;

  VisemeEvent(this.audioOffset, this.visemeId);
}
