import 'package:flutter/material.dart';

class SizedBoxNormal extends StatelessWidget {
  const SizedBoxNormal(this.boxHeight, this.boxWidth, {super.key});

  final double boxHeight;
  final double boxWidth;

  @override
  Widget build(BuildContext context) {
    return SizedBox(height: boxHeight, width: boxWidth,);
  }
  //
}