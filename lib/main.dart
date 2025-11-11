import 'package:fish_clicker/counter.dart';
import 'package:fish_clicker/fish_logo.dart';
import 'package:fish_clicker/leaderboard.dart';
import 'package:fish_clicker/model.dart';
import 'package:fish_clicker/settings.dart';
import 'package:fish_clicker/spinning_fish.dart';
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
          seedColor: Colors.purple,
          brightness: Brightness.dark,
        ),
      ),
      home: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          title: FishLogo(),
          centerTitle: true,
          leading: Builder(
            builder: (context) => IconButton(
              icon: Icon(Icons.leaderboard),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          ),
          actions: [
            Builder(
              builder: (context) => IconButton(
                icon: Icon(Icons.settings),
                onPressed: () => Scaffold.of(context).openEndDrawer(),
              ),
            ),
          ],
        ),
        body: Home(),
        drawer: Leaderboard(),
        endDrawer: Settings(),
      ),
    );
  }
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  void initState() {
    super.initState();
    if (FishClickerModel().userId == null ||
        FishClickerModel().userId!.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Scaffold.of(context).openEndDrawer();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [SpinningFish(), Counter()]);
  }
}
