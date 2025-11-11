import 'package:fish_clicker/model.dart';
import 'package:flutter/material.dart';

class SyncIndicator extends StatefulWidget {
  const SyncIndicator({super.key});

  @override
  State<SyncIndicator> createState() => _SyncIndicatorState();
}

class _SyncIndicatorState extends State<SyncIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 30),
    );

    _sync();

    FishClickerModel().syncNotifier.addListener(_sync);
  }

  void _sync() {
    _animationController
      ..reset()
      ..animateTo(1, curve: Curves.decelerate);
    setState(() {});
  }

  @override
  void dispose() {
    FishClickerModel().syncNotifier.removeListener(_sync);
    _animationController.dispose();
    super.dispose();
  }

  Color get color => FishClickerModel().syncNotifier.value % 2 == 0
      ? Colors.purple
      : Colors.purple[900]!;

  Color get backgroundColor => FishClickerModel().syncNotifier.value % 2 == 0
      ? Colors.purple[900]!
      : Colors.purple;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) => CircularProgressIndicator(
        value: 1 - _animationController.value,
        color: color,
        strokeWidth: 8,
        strokeAlign: BorderSide.strokeAlignInside,
        backgroundColor: backgroundColor,
      ),
    );
  }
}
