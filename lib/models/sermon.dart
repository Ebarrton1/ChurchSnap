import 'package:flutter/material.dart';

class Sermon {
  final String title;
  final String speaker;
  final String scripture;
  final String duration;
  final IconData icon;

  const Sermon({
    required this.title,
    required this.speaker,
    required this.scripture,
    required this.duration,
    this.icon = Icons.play_circle_fill_rounded,
  });
}
