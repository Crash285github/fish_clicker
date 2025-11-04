import 'package:fish_clicker/model.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class Leaderboard extends StatefulWidget {
  const Leaderboard({super.key});

  @override
  State<Leaderboard> createState() => _LeaderboardState();
}

class _LeaderboardState extends State<Leaderboard> {
  String? version;

  @override
  void initState() {
    super.initState();
    PackageInfo.fromPlatform().then((packageInfo) {
      setState(() => version = packageInfo.version);
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: FishClickerModel(),
      builder: (context, child) {
        int i = 0;
        return SafeArea(
          child: Drawer(
            shape: ContinuousRectangleBorder(
              borderRadius: BorderRadiusGeometry.circular(64.0),
              side: BorderSide(color: Colors.purple, width: 12.0),
            ),

            child: Column(
              children: [
                Text(
                  'Leaderboard',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontFamily: 'BabyDoll',
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.all(16.0),
                    children: [
                      Divider(),
                      ...FishClickerModel().leaderboard
                          .take(100)
                          .map(
                            (user) => Row(
                              children: [
                                Text(
                                  "${++i}.",
                                  style: TextStyle(
                                    fontSize: 20,
                                    color: Colors.orange,
                                    fontFamily: 'BabyDoll',
                                  ),
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0,
                                    ),
                                    child: Text(
                                      user.id,
                                      style: TextStyle(
                                        fontSize: 20,
                                        color:
                                            user.id == FishClickerModel().userId
                                            ? Colors.yellow
                                            : Colors.blue,
                                        fontFamily: 'BabyDoll',
                                        fontWeight: FontWeight.bold,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                                Text(
                                  "${user.clicks}",
                                  style: TextStyle(
                                    fontSize: 20,
                                    color: Colors.grey,
                                    fontFamily: 'BabyDoll',
                                  ),
                                ),
                              ],
                            ),
                          ),
                    ],
                  ),
                ),
                InkWell(
                  onTap: () async => await launchUrl(
                    Uri.parse(
                      'https://github.com/Crash285github/fish_clicker/releases',
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12.0,
                      vertical: 8.0,
                    ),
                    child: Row(
                      children: [
                        Text(
                          'Version: ${version ?? "Loading..."}',
                          style: TextStyle(
                            color: Colors.yellow,
                            fontSize: 20,
                            fontFamily: 'BabyDoll',
                          ),
                        ),
                        Spacer(),
                        Icon(Icons.info_outline, color: Colors.blue),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
