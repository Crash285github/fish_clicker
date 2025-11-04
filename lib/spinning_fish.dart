import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:gif/gif.dart';

class SpinningFish extends StatefulWidget {
  const SpinningFish({super.key});

  @override
  State<SpinningFish> createState() => _SpinningFishState();
}

class _SpinningFishState extends State<SpinningFish>
    with SingleTickerProviderStateMixin {
  late final GifController _gifController;
  late final Timer _clickDecreaseTimer;
  bool holding = false;
  int clicksPerSecond = 0;

  @override
  void initState() {
    super.initState();
    _gifController = GifController(vsync: this);
    _clickDecreaseTimer = Timer.periodic(const Duration(milliseconds: 300), (
      _,
    ) {
      if (clicksPerSecond > 0) {
        setState(() => clicksPerSecond -= 1);
        if (clicksPerSecond == 0) {
          _gifController.stop();
        } else {
          _gifController
            ..stop()
            ..repeat();
        }
      }
    });
  }

  @override
  void dispose() {
    _gifController.dispose();
    _clickDecreaseTimer.cancel();
    super.dispose();
  }

  Color get glowColor {
    if (clicksPerSecond >= 10) {
      return Colors.red.withAlpha(255);
    } else if (clicksPerSecond >= 5) {
      return Colors.orange.withAlpha(255);
    } else if (clicksPerSecond >= 2) {
      return Colors.green.withAlpha(255);
    } else {
      return Colors.white.withAlpha(255);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (clicksPerSecond < 12) {
          setState(() => clicksPerSecond += 1);
          _gifController
            ..stop()
            ..repeat();
        }
      },
      onTapDown: (_) => setState(() => holding = true),
      onTapUp: (_) => setState(() => holding = false),
      onTapCancel: () => setState(() => holding = false),
      child: AnimatedScale(
        scale: holding ? 1.1 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Stack(
          alignment: Alignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 100),
              clipBehavior: Clip.none,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [glowColor, Colors.transparent],
                  stops: const [.1, 1.0],
                ),
              ),
            ),
            Gif(
              image: AssetImage('assets/spinning_fish.gif'),
              controller: _gifController,
              fps: min(600, clicksPerSecond * 60 + 1),
            ),
          ],
        ),
      ),
    );
  }
}
