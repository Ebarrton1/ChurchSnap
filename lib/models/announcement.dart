import 'package:flutter/material.dart';

class Announcement {
  final String title;
  final String message;
  final String tag;
  final IconData icon;

  const Announcement({
    required this.title,
    required this.message,
    required this.tag,
    this.icon = Icons.campaign_rounded,
  });
}
