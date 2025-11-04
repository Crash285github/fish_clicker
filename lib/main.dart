import 'package:fish_clicker/counter.dart';
import 'package:fish_clicker/model.dart';
import 'package:fish_clicker/spinning_fish.dart';
import 'package:fish_clicker/username.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FishClickerModel().init();
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
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(child: SpinningFish()),
            Counter(),
            Username()
          ],
        ),
      ),
    );
  }
}
