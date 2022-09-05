import 'package:flutter/material.dart';

class Player extends StatelessWidget {
  final bool closeMouth;
  const Player({Key? key, required this.closeMouth}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      "assets/images/pacman.png",
      height: 20,
      width: 20,
    );
  }
}
