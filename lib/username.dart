import 'package:fish_clicker/model.dart';
import 'package:flutter/material.dart';

class Username extends StatefulWidget {
  const Username({super.key});

  @override
  State<Username> createState() => _UsernameState();
}

class _UsernameState extends State<Username> {
  final TextEditingController _controller = TextEditingController(
    text: FishClickerModel().userId ?? '',
  );

  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  DateTime? lastUpdate;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width / 2,
            child: TextField(
              maxLength: 20,
              focusNode: _focusNode,
              controller: _controller,

              decoration: InputDecoration(
                border: UnderlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: BorderSide(color: Colors.purple, width: 4.0),
                ),
                enabledBorder: UnderlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: BorderSide(color: Colors.purple, width: 4.0),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: BorderSide(color: Colors.orange, width: 4.0),
                ),

                labelText: "Username (required)",
                labelStyle: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'BabyDoll',
                ),
                floatingLabelAlignment: FloatingLabelAlignment.center,
                floatingLabelBehavior: FloatingLabelBehavior.always,
              ),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.yellow,
                fontSize: 24,
                fontWeight: FontWeight.bold,
                fontFamily: 'BabyDoll',
              ),
              onSubmitted: (value) => FishClickerModel().userId = value.trim(),
            ),
          ),
          TextButton(
            onPressed: () {
              FishClickerModel().userId = _controller.text.trim();
              _focusNode.unfocus();
            },

            style: ButtonStyle(
              shape: WidgetStatePropertyAll(
                ContinuousRectangleBorder(
                  borderRadius: BorderRadiusGeometry.circular(24.0),
                  side: BorderSide(color: Colors.yellow, width: 2.0),
                ),
              ),
              padding: WidgetStatePropertyAll(
                EdgeInsets.symmetric(horizontal: 24.0, vertical: 0.0),
              ),
            ),
            child: Text(
              "Confirm",
              style: TextStyle(
                fontSize: 20,
                color: Colors.yellow,
                fontFamily: 'BabyDoll',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
