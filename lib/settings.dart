import 'package:fish_clicker/model.dart';
import 'package:fish_clicker/username.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  String? version;
  @override
  void initState() {
    super.initState();
    PackageInfo.fromPlatform().then(
      (info) => setState(() => version = info.version),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Drawer(
          shape: ContinuousRectangleBorder(
            borderRadius: BorderRadiusGeometry.circular(64.0),
            side: BorderSide(color: Colors.purple, width: 12.0),
          ),
          child: Column(
            children: [
              Text(
                'Settings',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontFamily: 'BabyDoll',
                ),
              ),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.all(16),
                  children: [
                    Divider(),
                    ListenableBuilder(
                      listenable: FishClickerModel(),
                      builder: (context, child) => Card(
                        margin: EdgeInsets.zero,
                        surfaceTintColor: Colors.blue,
                        shape: ContinuousRectangleBorder(
                          borderRadius: BorderRadiusGeometry.circular(16.0),
                          side: BorderSide(
                            color: FishClickerModel().muteAudio
                                ? Colors.red
                                : Colors.green,
                            width: 4.0,
                          ),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: InkWell(
                          onTap: () => FishClickerModel().muteAudio =
                              !FishClickerModel().muteAudio,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                Text(
                                  'App sounds',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.white,
                                    fontFamily: 'BabyDoll',
                                  ),
                                ),
                                Spacer(),
                                Text(
                                  FishClickerModel().muteAudio ? 'NO' : 'YES',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: FishClickerModel().muteAudio
                                        ? Colors.red
                                        : Colors.green,
                                    fontFamily: 'BabyDoll',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Card(
                margin: EdgeInsets.symmetric(horizontal: 16.0),
                surfaceTintColor: Colors.blue,
                shape: ContinuousRectangleBorder(
                  borderRadius: BorderRadiusGeometry.circular(32.0),
                  side: BorderSide(color: Colors.yellow, width: 4.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Username(),
                ),
              ),
              SizedBox(height: 12.0),
              InkWell(
                onTap: kIsWeb
                    ? null
                    : () async => await launchUrl(
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
                      if (!kIsWeb) Icon(Icons.update, color: Colors.blue),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
