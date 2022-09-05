import 'package:flutter/material.dart';

class MyPixel extends StatelessWidget {
  final Color innerColor;
  final Color outerColor;

  const MyPixel({Key? key, required this.innerColor, required this.outerColor})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(1.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(2),
        child: Container(
          padding: const EdgeInsets.all(4),
          color: outerColor,
          child: Padding(
            padding: const EdgeInsets.all(1.0),
            child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Container(color: innerColor)),
          ),
        ),
      ),
    );
  }
}
