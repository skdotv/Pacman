import 'package:flutter/material.dart';

class Ghost extends StatelessWidget {
  const Ghost({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      "assets/images/ghost.png",
      height: 20,
      width: 20,
    );
  }
}
