import 'package:flutter/material.dart';

class TypingAnimaton extends StatefulWidget {
  final double horizontal;
  final double vertical;

  const TypingAnimaton(
      {super.key, required this.horizontal, required this.vertical});

  @override
  State<TypingAnimaton> createState() => _TypingAnimatonState();
}

class _TypingAnimatonState extends State<TypingAnimaton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation1;
  late Animation<double> _opacityAnimation2;
  late Animation<double> _opacityAnimation3;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    const interval = Interval(0, 1, curve: Curves.easeInOut);
    final opacityTween = Tween<double>(begin: 0.2, end: 0.8);

    _opacityAnimation1 = opacityTween.animate(
      CurvedAnimation(
        parent: _controller,
        curve: interval,
      ),
    );

    _opacityAnimation2 = opacityTween.animate(
      CurvedAnimation(
        parent: _controller,
        curve: interval,
      ).drive(Tween(begin: 0.4, end: 0.2)),
    );

    _opacityAnimation3 = opacityTween.animate(
      CurvedAnimation(
        parent: _controller,
        curve: interval,
      ).drive(Tween(begin: 0.6, end: 0.4)),
    );

    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: widget.horizontal, vertical: widget.vertical),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Opacity(
                opacity: _opacityAnimation1.value,
                child: child,
              );
            },
            child: Container(
              width: 10,
              height: 10,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.blue,
              ),
            ),
          ),
          const SizedBox(width: 8),
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Opacity(
                opacity: _opacityAnimation2.value,
                child: child,
              );
            },
            child: Container(
              width: 10,
              height: 10,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.blue,
              ),
            ),
          ),
          const SizedBox(width: 8),
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Opacity(
                opacity: _opacityAnimation3.value,
                child: child,
              );
            },
            child: Container(
              width: 10,
              height: 10,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.blue,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
