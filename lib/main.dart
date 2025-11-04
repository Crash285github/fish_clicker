import 'package:fish_clicker/counter.dart';
import 'package:fish_clicker/leaderboard.dart';
import 'package:fish_clicker/model.dart';
import 'package:fish_clicker/spinning_fish.dart';
import 'package:fish_clicker/username.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
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
          leading: Builder(
            builder: (context) => IconButton(
              icon: Icon(Icons.leaderboard),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          ),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Spacer(flex: 3),
            Center(child: SpinningFish()),
            Counter(),
            Spacer(flex: 3),
            Username(),
            Spacer(),
          ],
        ),
        drawer: Leaderboard(),
      ),
    );
  }
}
