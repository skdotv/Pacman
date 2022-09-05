import 'package:flutter/material.dart';

class Score extends StatelessWidget {
  const Score({
    Key? key,
    required this.score,
  }) : super(key: key);

  final int score;

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
          text: "Score\n",
          style: const TextStyle(color: Colors.white, fontSize: 30),
          children: [
            TextSpan(
              text: "$score",
              style: TextStyle(color: Colors.green[600], fontSize: 40),
            ),
          ]),
    );
  }
}
