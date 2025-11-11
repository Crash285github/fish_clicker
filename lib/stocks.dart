import 'dart:ui';

import 'package:fish_clicker/model.dart';
import 'package:fish_clicker/sync_indicator.dart';
import 'package:flutter/material.dart';

class Stocks extends StatefulWidget {
  const Stocks({super.key});

  @override
  State<Stocks> createState() => _StocksState();
}

class _StocksState extends State<Stocks> {
  final DraggableScrollableController _controller =
      DraggableScrollableController();

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
          child: ListenableBuilder(
            listenable: FishClickerModel(),
            builder: (context, child) => Card(
              margin: EdgeInsets.all(16.0),
              surfaceTintColor: Colors.green,
              shape: ContinuousRectangleBorder(
                borderRadius: BorderRadiusGeometry.circular(64.0),
                side: BorderSide(color: Colors.green, width: 8.0),
              ),
              clipBehavior: Clip.antiAlias,
              child: Stack(
                children: [
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
                              Text(
                                "Stocks: ${FishClickerModel().stocks}",
                                style: TextStyle(
                                  fontSize: 32,
                                  fontFamily: 'BabyDoll',
                                ),
                              ),
                              Text(
                                "Your money: ${FishClickerModel().money.toStringAsFixed(2)}\$",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontFamily: 'BabyDoll',
                                ),
                              ),
                              const SizedBox(height: 12.0),
                              TextButton(
                                style: ButtonStyle(
                                  shape: WidgetStateProperty.fromMap({
                                    WidgetState
                                        .disabled: ContinuousRectangleBorder(
                                      borderRadius:
                                          BorderRadiusGeometry.circular(24.0),
                                      side: BorderSide(
                                        color: Colors.black,
                                        width: 4.0,
                                      ),
                                    ),
                                    WidgetState.any: ContinuousRectangleBorder(
                                      borderRadius:
                                          BorderRadiusGeometry.circular(24.0),
                                      side: BorderSide(
                                        color: Colors.yellow,
                                        width: 4.0,
                                      ),
                                    ),
                                  }),
                                ),
                                onPressed:
                                    FishClickerModel().convertMoneyToPoints,
                                child: Text(
                                  "Convert to points",
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.yellow,
                                    fontFamily: 'BabyDoll',
                                  ),
                                ),
                              ),
                              Spacer(),
                              Text(
                                "Value: ${FishClickerModel().stockPrice.toStringAsFixed(2)}\$",
                                style: TextStyle(
                                  fontSize: 32,
                                  fontFamily: 'BabyDoll',
                                  color: Colors.green,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              SyncIndicator(),
                              Spacer(),
                              TextButton(
                                style: ButtonStyle(
                                  shape: WidgetStateProperty.fromMap({
                                    WidgetState
                                        .disabled: ContinuousRectangleBorder(
                                      borderRadius:
                                          BorderRadiusGeometry.circular(24.0),
                                      side: BorderSide(
                                        color: Colors.black,
                                        width: 4.0,
                                      ),
                                    ),
                                    WidgetState.any: ContinuousRectangleBorder(
                                      borderRadius:
                                          BorderRadiusGeometry.circular(24.0),
                                      side: BorderSide(
                                        color: Colors.blue,
                                        width: 4.0,
                                      ),
                                    ),
                                  }),
                                ),
                                onPressed: FishClickerModel().buyStock,
                                child: Text(
                                  "Buy",
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.blue,
                                    fontFamily: 'BabyDoll',
                                  ),
                                ),
                              ),
                              SizedBox(height: 12.0),
                              TextButton(
                                style: ButtonStyle(
                                  shape: WidgetStateProperty.fromMap({
                                    WidgetState
                                        .disabled: ContinuousRectangleBorder(
                                      borderRadius:
                                          BorderRadiusGeometry.circular(24.0),
                                      side: BorderSide(
                                        color: Colors.black,
                                        width: 4.0,
                                      ),
                                    ),
                                    WidgetState.any: ContinuousRectangleBorder(
                                      borderRadius:
                                          BorderRadiusGeometry.circular(24.0),
                                      side: BorderSide(
                                        color: Colors.orange,
                                        width: 4.0,
                                      ),
                                    ),
                                  }),
                                ),
                                onPressed: FishClickerModel().sellStock,
                                child: Text(
                                  "Sell",
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.orange,
                                    fontFamily: 'BabyDoll',
                                  ),
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
      ),
    );
  }
}
