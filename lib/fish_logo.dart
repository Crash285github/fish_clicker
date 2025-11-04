import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class FishLogo extends StatefulWidget {
  const FishLogo({super.key});

  @override
  State<FishLogo> createState() => _FishLogoState();
}

class _FishLogoState extends State<FishLogo> {
  bool holding = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => holding = true),
      onTapUp: (_) async {
        setState(() => holding = false);
        await showDialog(
          context: context,
          builder: (context) => DiscordDialog(),
        );
      },
      onTapCancel: () => setState(() => holding = false),
      child: AnimatedScale(
        duration: const Duration(milliseconds: 100),
        scale: holding ? 0.9 : 1.0,
        child: Image.asset(
          'assets/fish.png',
          height: kToolbarHeight / 2,
          color: holding ? Colors.blue : null,
        ),
      ),
    );
  }
}

class DiscordDialog extends StatelessWidget {
  const DiscordDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: ContinuousRectangleBorder(
        borderRadius: BorderRadius.circular(64),
        side: BorderSide(color: Colors.yellow, width: 3),
      ),
      title: Text(
        "Open discord?",
        textAlign: TextAlign.center,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 24,
          fontFamily: 'BabyDoll',
          decoration: TextDecoration.underline,
        ),
      ),
      actionsAlignment: MainAxisAlignment.spaceBetween,
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            "Cancel",
            style: TextStyle(
              fontFamily: 'BabyDoll',
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: Colors.red,
            ),
          ),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            launchUrl(
              Uri.parse("https://discord.gg/Z34mSSM"),
              mode: LaunchMode.externalApplication,
            );
          },
          child: Text(
            "Open",
            style: TextStyle(
              fontFamily: 'BabyDoll',
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Colors.blue,
            ),
          ),
        ),
      ],
    );
  }
}
