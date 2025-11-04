import 'package:fish_clicker/spinning_fish.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.from(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Image.asset('assets/fish.png', height: kToolbarHeight / 2),
          centerTitle: true,
        ),
        body: Center(child: SpinningFish()),
      ),
    );
  }
}
