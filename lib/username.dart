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

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  DateTime? lastUpdate;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Spacer(),
          SizedBox(
            width: MediaQuery.of(context).size.width / 2,
            child: TextField(
              maxLength: 20,
              controller: _controller,
              onTapOutside: (event) => FocusScope.of(context).unfocus(),
              decoration: const InputDecoration(
                border: UnderlineInputBorder(),
                labelText: "Username (required)",
                floatingLabelAlignment: FloatingLabelAlignment.center,
                floatingLabelBehavior: FloatingLabelBehavior.always,
              ),
              textAlign: TextAlign.center,
              onSubmitted: (value) => FishClickerModel().userId = value.trim(),
            ),
          ),
          Expanded(
            flex: 1,
            child: IconButton(
              onPressed: () =>
                  FishClickerModel().userId = _controller.text.trim(),
              icon: Icon(Icons.send),
            ),
          ),
        ],
      ),
    );
  }
}
