import 'dart:async';
import 'package:chatbot/services/chat_gpt_api.dart';
import 'package:chatbot/services/speech_to_text_api.dart';
import 'package:chatbot/utils/format_number_utils.dart';
import 'package:chatbot/model/chat_message.dart';
import 'package:chatbot/widgets/record_control_widget.dart';
import 'package:chatbot/widgets/sliding_up_panel_widget.dart';
import 'package:chatbot/widgets/typing_animation.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:record/record.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class SpeechScreen extends StatefulWidget {
  final void Function(String path) onStop;

  const SpeechScreen({Key? key, required this.onStop}) : super(key: key);

  @override
  State<SpeechScreen> createState() => _SpeechScreenState();
}

class _SpeechScreenState extends State<SpeechScreen> {
  int _recordDuration = 0;
  Timer? _timer;
  late Record _audioRecorder;
  RecordState _recordState = RecordState.stop;
  String? _transcript;
  bool? isSending;

  final panelController = PanelController();

  final List<ChatMessage> messages = [
    /*ChatMessage(
      transcript: "You are an assistant that speaks like Shakespeare",
      type: ChatType.user,
    ),*/
  ];

  @override
  void initState() {
    _audioRecorder = Record();
    if (kDebugMode) {
      print("object");
      print(_transcript);
    }
    super.initState();
  }

  void _setRecordState(RecordState state) {
    setState(() {
      _recordState = state;
    });
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

  Future<void> _stop() async {
    _timer?.cancel();
    _recordDuration = 0;

    _setRecordState(RecordState.stop);

    final path = await _audioRecorder.stop();

    if (path != null) {
      widget.onStop(path);

      try {
        final transcript = await getSTTData(path);

        if (transcript == null) {
          setState(() {
            isSending = false;
          });

          _showErrorDialog();

          return;
        }

        setState(() {
          messages.add(
            ChatMessage(
              transcript: transcript,
              type: ChatType.user,
            ),
          );
        });

        String? answer = (await ApiChatGPT().getGPTData(messages))?.trim();

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
      } catch (e) {
        // Code to handle error
      } finally {
        setState(() {
          isSending = false;
        });
      }

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

  @override
  Widget build(BuildContext context) {
    final panelHeightOpen = MediaQuery.of(context).size.height * 0.85;
    final screenWidth = MediaQuery.of(context).size.width;

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
                Padding(
                  padding: const EdgeInsets.only(top: 50, bottom: 20),
                  child: Container(
                    width: 300.0,
                    height: 300.0,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white,
                        width: 1.0,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(150.0),
                      child: Image.asset(
                        'assets/images/chatbot_cartoon.png',
                        fit: BoxFit.cover,
                      ),
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
