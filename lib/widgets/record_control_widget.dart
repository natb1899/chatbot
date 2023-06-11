import 'package:flutter/material.dart';

class RecordControl extends StatefulWidget {
  final Function start;
  final Function stop;

  const RecordControl({Key? key, required this.start, required this.stop})
      : super(key: key);

  @override
  State<RecordControl> createState() => _RecordControlState();
}

class _RecordControlState extends State<RecordControl> {
  bool _isListening = false;
  bool _isTapped = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (details) async {
        setState(() {
          _isTapped = true;
          _isListening = true;
          widget.start();
        });
      },
      onTapUp: (details) async {
        setState(() {
          _isTapped = false;
          _isListening = false;
          widget.stop();
        });
      },
      onTapCancel: () {
        setState(() {
          _isTapped = false;
          _isListening = false;
        });
      },
      child: SizedBox(
        height: 75,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                _isTapped
                    ? Theme.of(context).colorScheme.tertiary
                    : Theme.of(context).colorScheme.primary,
                _isTapped
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.tertiary,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).colorScheme.primary,
                spreadRadius: 2,
                blurRadius: 5,
                offset: const Offset(0, 3), // changes position of shadow
              ),
            ],
          ),
          child: Center(
            child: Icon(
              _isListening ? Icons.mic : Icons.mic_none,
              color: Theme.of(context).indicatorColor,
              size: 32,
            ),
          ),
        ),
      ),
    );
  }
}
