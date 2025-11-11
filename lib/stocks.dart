import 'dart:ui';

import 'package:fish_clicker/model.dart';
import 'package:fish_clicker/sync_indicator.dart';
import 'package:flutter/material.dart';

class Stocks extends StatefulWidget {
  const Stocks({super.key});

  @override
  State<Stocks> createState() => _StocksState();
}

class _StocksState extends State<Stocks> with SingleTickerProviderStateMixin {
  final DraggableScrollableController _controller =
      DraggableScrollableController();

  AnimationController? _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
      upperBound: double.infinity,
      value: FishClickerModel().stockPrice,
    );

    FishClickerModel().addListener(_updateValue);
  }

  @override
  void dispose() {
    FishClickerModel().removeListener(_updateValue);
    _animationController?.dispose();
    super.dispose();
  }

  void _updateValue() {
    _animationController?.animateTo(
      FishClickerModel().stockPrice,
      curve: Curves.linear,
    );
  }

  bool get canBuy =>
      FishClickerModel().money >= _animationController!.value &&
      FishClickerModel().canBuyOrSellStocks;

  bool get canSell =>
      FishClickerModel().stocks >= 1 && FishClickerModel().canBuyOrSellStocks;

  @override
  Widget build(BuildContext context) {
    final minSize = 250 / MediaQuery.sizeOf(context).height;
    final height = 270;

    return SizedBox(
      height: height + 20,
      child: DraggableScrollableSheet(
        controller: _controller,
        maxChildSize: 1,
        minChildSize: minSize,
        initialChildSize: minSize,
        snap: true,
        snapSizes: [minSize, 1.0],
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          child: Card(
            margin: EdgeInsets.all(16.0),
            surfaceTintColor: Colors.green,
            shape: ContinuousRectangleBorder(
              borderRadius: BorderRadiusGeometry.circular(64.0),
              side: BorderSide(color: Colors.green, width: 8.0),
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              children: [
                // Background image
                Opacity(
                  opacity: 0.1,
                  child: ImageFiltered(
                    imageFilter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
                    child: Image.asset(
                      'assets/stonks.jpg',
                      colorBlendMode: BlendMode.color,
                      fit: BoxFit.fill,
                      height: height.toDouble(),
                      width: MediaQuery.sizeOf(context).width,
                      color: Colors.green,
                    ),
                  ),
                ),
                SizedBox(
                  height: height.toDouble(),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ListenableBuilder(
                              listenable: FishClickerModel(),
                              builder: (context, child) => Text(
                                "Stocks: ${FishClickerModel().stocks}",
                                style: TextStyle(
                                  fontSize: 32,
                                  fontFamily: 'BabyDoll',
                                ),
                              ),
                            ),
                            ListenableBuilder(
                              listenable: FishClickerModel(),
                              builder: (context, child) => Text(
                                "Your money: ${FishClickerModel().money.toStringAsFixed(2)}\$",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontFamily: 'BabyDoll',
                                ),
                              ),
                            ),
                            const SizedBox(height: 12.0),
                            ListenableBuilder(
                              listenable: FishClickerModel(),
                              builder: (context, child) => _Button(
                                color: Colors.yellow,
                                text: "Convert to points",
                                onPressed:
                                    FishClickerModel().convertMoneyToPoints,
                              ),
                            ),
                            Spacer(),
                            AnimatedBuilder(
                              animation: _animationController!,
                              builder: (context, child) => Text(
                                "Value: ${_animationController!.value.toStringAsFixed(2)}\$",
                                style: TextStyle(
                                  fontSize: 32,
                                  fontFamily: 'BabyDoll',
                                  color: Colors.green,
                                ),
                              ),
                            ),
                          ],
                        ),

                        // Buttons
                        Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            SyncIndicator(),
                            Spacer(),
                            AnimatedBuilder(
                              animation: _animationController!,
                              builder: (context, child) => _Button(
                                color: Colors.blue,
                                text: "Buy",
                                onPressed: canBuy
                                    ? () => FishClickerModel().buyStock(
                                        _animationController!.value,
                                      )
                                    : null,
                              ),
                            ),
                            SizedBox(height: 12.0),
                            AnimatedBuilder(
                              animation: _animationController!,
                              builder: (context, child) => _Button(
                                color: Colors.orange,
                                text: "Sell",
                                onPressed: canSell
                                    ? () => FishClickerModel().sellStock(
                                        _animationController!.value,
                                      )
                                    : null,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Button extends StatelessWidget {
  const _Button({this.onPressed, required this.color, required this.text});

  final Function()? onPressed;
  final Color color;
  final String text;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: ButtonStyle(
        shape: WidgetStateProperty.fromMap({
          WidgetState.disabled: ContinuousRectangleBorder(
            borderRadius: BorderRadiusGeometry.circular(24.0),
            side: BorderSide(color: Colors.black, width: 4.0),
          ),
          WidgetState.any: ContinuousRectangleBorder(
            borderRadius: BorderRadiusGeometry.circular(24.0),
            side: BorderSide(color: color, width: 4.0),
          ),
        }),
        foregroundColor: WidgetStateProperty.fromMap({
          WidgetState.disabled: null,
          WidgetState.any: color,
        }),
        backgroundColor: WidgetStateProperty.fromMap({
          WidgetState.disabled: color.withAlpha(20),
          WidgetState.any: color.withAlpha(70),
        }),
        overlayColor: WidgetStateProperty.fromMap({
          WidgetState.pressed: color.withAlpha(100),
        }),
      ),
      onPressed: onPressed,
      child: Text(text, style: TextStyle(fontSize: 18, fontFamily: 'BabyDoll')),
    );
  }
}
