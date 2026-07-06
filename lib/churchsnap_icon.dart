import 'package:flutter/material.dart';

class ChurchSnapIcon extends StatelessWidget {
  final String name;
  final double size;

  const ChurchSnapIcon({super.key, required this.name, this.size = 26});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/icons/$name.png',
      width: size,
      height: size,
      fit: BoxFit.contain,
    );
  }
}
