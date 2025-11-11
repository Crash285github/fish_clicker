import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:fish_clicker/model.dart';
import 'package:fish_clicker/sync_indicator.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class Stocks extends StatefulWidget {
  const Stocks({super.key});

  @override
  State<Stocks> createState() => _StocksState();
}

class _StocksState extends State<Stocks>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  final DraggableScrollableController _controller =
      DraggableScrollableController();

  AnimationController? _priceAnimator;
  AnimationController? _moneyAnimator;

  @override
  void initState() {
    super.initState();
    _priceAnimator = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
      upperBound: double.infinity,
      value: FishClickerModel().stockPrice,
    );

    _moneyAnimator = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
      upperBound: double.infinity,
      value: FishClickerModel().money,
    );

    FishClickerModel().addListener(_updateValue);
    FishClickerModel().addListener(_updateMoney);

    _controller.addListener(_updateIsPanelAtTop);
  }

  void _updateIsPanelAtTop() {
    if (_controller.isAttached) {
      final newValue = _controller.size > 0.5;

      if (newValue != isPanelAtTop) {
        setState(() => isPanelAtTop = newValue);
      }
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_updateIsPanelAtTop);
    FishClickerModel().removeListener(_updateValue);
    FishClickerModel().removeListener(_updateMoney);
    _priceAnimator?.dispose();
    _moneyAnimator?.dispose();
    super.dispose();
  }

  void _updateValue() => _priceAnimator?.animateTo(
    FishClickerModel().stockPrice,
    curve: Curves.linear,
  );

  void _updateMoney() =>
      _moneyAnimator?.animateTo(FishClickerModel().money, curve: Curves.linear);

  bool get canBuy =>
      _moneyAnimator!.value >= _priceAnimator!.value && enabledButtons;
  bool get canSell => FishClickerModel().stocks >= 1 && enabledButtons;

  bool enabledButtons = true;

  double get panelTapDestination => isPanelAtTop ? 0 : 1.0;

  bool isPanelAtTop = false;

  final FocusNode _focusNode = FocusNode();

  void _handleKeyEvent(KeyEvent event) {
    if (!kIsWeb) return;

    if (event.logicalKey.keyLabel == "I" && canBuy) {
      _buy();
    }

    if (event.logicalKey.keyLabel == "K" && canSell) {
      _sell();
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final minSize = 210 / MediaQuery.sizeOf(context).height;
    final height = 270;

    return KeyboardListener(
      focusNode: _focusNode,
      autofocus: true,
      onKeyEvent: _handleKeyEvent,
      child: SizedBox(
        height: height + 50,
        width: min(600, MediaQuery.of(context).size.width),
        child: DraggableScrollableSheet(
          controller: _controller,
          maxChildSize: 1,
          minChildSize: minSize,
          initialChildSize: minSize,
          snap: true,
          snapSizes: [minSize, 1.0],
          builder: (context, scrollController) => SingleChildScrollView(
            controller: scrollController,
            physics: NeverScrollableScrollPhysics(),
            child: Stack(
              children: [
                Card(
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
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
                                  AnimatedBuilder(
                                    animation: _moneyAnimator!,
                                    builder: (context, child) => Text(
                                      "Your money: ${_moneyAnimator!.value.toStringAsFixed(2)}\$",
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
                                      onPressed: FishClickerModel()
                                          .convertMoneyToPoints,
                                    ),
                                  ),
                                  Spacer(),
                                  AnimatedBuilder(
                                    animation: _priceAnimator!,
                                    builder: (context, child) => Text(
                                      "Value: ${_priceAnimator!.value.toStringAsFixed(2)}\$",
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
                                    animation: _priceAnimator!,
                                    builder: (context, child) => _Button(
                                      color: Colors.blue,
                                      text: kIsWeb
                                          ? "[I] Buy stock"
                                          : "Buy stock",
                                      onPressed: canBuy ? _buy : null,
                                    ),
                                  ),
                                  SizedBox(height: 12.0),
                                  AnimatedBuilder(
                                    animation: _priceAnimator!,
                                    builder: (context, child) => _Button(
                                      color: Colors.orange,
                                      text: kIsWeb
                                          ? "[K] Sell stock"
                                          : "Sell stock",
                                      onPressed: canSell ? _sell : null,
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
                Align(
                  alignment: Alignment(0.3, 0),
                  child: Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: TextButton(
                      style: ButtonStyle(
                        backgroundColor: WidgetStatePropertyAll(Colors.black87),
                        foregroundColor: WidgetStatePropertyAll(Colors.white),
                        shape: WidgetStatePropertyAll(
                          ContinuousRectangleBorder(
                            borderRadius: BorderRadiusGeometry.circular(24.0),
                            side: BorderSide(color: Colors.green, width: 4.0),
                          ),
                        ),
                      ),
                      onPressed: () {
                        _controller.animateTo(
                          panelTapDestination,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.decelerate,
                        );
                      },
                      child: SizedBox(
                        width: 48,
                        child: Icon(
                          size: 24,
                          isPanelAtTop
                              ? Icons.keyboard_arrow_down
                              : Icons.keyboard_arrow_up,
                        ),
                      ),
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

  _sell() {
    setState(() => enabledButtons = false);
    Future.delayed(
      const Duration(seconds: 1),
      () => setState(() => enabledButtons = true),
    );

    FishClickerModel().sellStock(_priceAnimator!.value);
  }

  _buy() {
    setState(() => enabledButtons = false);
    Future.delayed(
      const Duration(seconds: 1),
      () => setState(() => enabledButtons = true),
    );

    FishClickerModel().buyStock(_priceAnimator!.value);
  }

  @override
  bool get wantKeepAlive => true;
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
