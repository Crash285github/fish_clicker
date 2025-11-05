import 'package:fish_clicker/model.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class Counter extends StatefulWidget {
  const Counter({super.key});

  @override
  State<Counter> createState() => _CounterState();
}

class _CounterState extends State<Counter> with SingleTickerProviderStateMixin {
  int multipleOf200 = 0;
  final audioPlayer = AudioPlayer();
  AnimationController? _animationController;

  @override
  void initState() {
    super.initState();
    audioPlayer.setAsset('assets/goldfish.mp3', preload: true);
    FishClickerModel().addListener(_updateRemainder);
    FishClickerModel().addListener(_updateValue);

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
      upperBound: double.infinity,
      value: FishClickerModel().globalClicks.toDouble(),
    );
  }

  @override
  void dispose() {
    FishClickerModel().removeListener(_updateRemainder);
    FishClickerModel().removeListener(_updateValue);
    super.dispose();
  }

  Future<void> _updateRemainder() async {
    final newMultipleOf200 = FishClickerModel().globalClicks ~/ 200;
    if (newMultipleOf200 != multipleOf200) {
      setState(() => multipleOf200 = newMultipleOf200);

      if (!FishClickerModel().muteAudio) {
        await audioPlayer.seek(Duration.zero);
        await audioPlayer.play();
      }
    }
  }

  void _updateValue() {
    _animationController?.animateTo(
      FishClickerModel().globalClicks.toDouble(),
      curve: Curves.easeOutCubic,
    );
  }

  String get percentageOfAllClicks =>
      (FishClickerModel().localClicks / FishClickerModel().globalClicks * 100)
          .toStringAsFixed(2);

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: FishClickerModel(),
      builder: (context, child) => AnimatedBuilder(
        animation: _animationController!,
        builder: (context, child) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FittedBox(
              child: Text(
                _animationController!.value.round().toString(),
                style: const TextStyle(
                  fontSize: 64,
                  fontFamily: 'BabyDoll',
                  color: Colors.yellow,
                ),
              ),
            ),
            FittedBox(
              child: Text(
                "Your clicks: ${FishClickerModel().localClicks}\n"
                "$percentageOfAllClicks% of all clicks\n",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 24,
                  fontFamily: 'BabyDoll',
                  color: Colors.purple,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
