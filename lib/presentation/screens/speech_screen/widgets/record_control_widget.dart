import 'package:chatbot/presentation/provider/recording_provider.dart';
import 'package:flutter/material.dart';

class RecordControl extends StatefulWidget {
  final Function start;
  final Function stop;
  final bool? isBlocked;
  final RecordingProvider isRecording;

  const RecordControl(
      {Key? key,
      required this.start,
      required this.stop,
      this.isBlocked,
      required this.isRecording})
      : super(key: key);

  @override
  State<RecordControl> createState() => _RecordControlState();
}

class _RecordControlState extends State<RecordControl> {
  @override
  Widget build(BuildContext context) {
    return widget.isBlocked!
        ? Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).colorScheme.error,
                  blurRadius: 5,
                  spreadRadius: 0.5,
                ),
              ],
            ),
            height: 75,
            child: Container(
              color: Theme.of(context).colorScheme.error,
              child: Center(
                child: Icon(
                  Icons.block_outlined,
                  color: Theme.of(context).indicatorColor,
                  size: 32,
                ),
              ),
            ),
          )
        : GestureDetector(
            onTapDown: (details) async {
              widget.isRecording.isRecording = true;
              widget.start();
            },
            onTapUp: (details) async {
              widget.isRecording.isRecording = false;
              widget.stop();
            },
            onPanEnd: (details) async {
              widget.isRecording.isRecording = false;
              widget.stop();
            },
            onTapCancel: () {
              widget.isRecording.isRecording = false;
            },
            child: Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).colorScheme.primary,
                    blurRadius: 5,
                    spreadRadius: 0.5,
                  ),
                ],
              ),
              height: 75,
              child: Container(
                color: Theme.of(context).colorScheme.primary,
                child: Center(
                  child: Icon(
                    widget.isRecording.isRecording ? Icons.mic : Icons.mic_none,
                    color: Theme.of(context).indicatorColor,
                    size: 32,
                  ),
                ),
              ),
            ),
          );
  }
}
