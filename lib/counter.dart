import 'package:fish_clicker/model.dart';
import 'package:flutter/material.dart';

class Counter extends StatelessWidget {
  const Counter({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: FishClickerModel(),
      builder: (context, child) => Text(
        FishClickerModel().globalClicks.toString(),
        style: const TextStyle(fontSize: 48, fontFamily: 'BabyDoll'),
      ),
    );
  }
}
