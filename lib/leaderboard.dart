import 'package:fish_clicker/model.dart';
import 'package:flutter/material.dart';

class Leaderboard extends StatelessWidget {
  const Leaderboard({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: FishClickerModel(),
      builder: (context, child) {
        int i = 0;
        return SafeArea(
          child: Drawer(
            child: ListView(
              padding: EdgeInsets.all(8.0),
              children: [
                Text(
                  'Leaderboard',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontFamily: 'BabyDoll',
                  ),
                ),
                Divider(),
                ...FishClickerModel().leaderboard.map(
                  (user) => Row(
                    children: [
                      Text(
                        "${++i}.",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.orange,
                          fontFamily: 'BabyDoll',
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text(
                            user.id,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.blue,
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
                          fontSize: 16,
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
        );
      },
    );
  }
}
