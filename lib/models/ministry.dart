import 'package:flutter/material.dart';

class Ministry {
  final String title;
  final String description;
  final String schedule;
  final IconData icon;

  const Ministry({
    required this.title,
    required this.description,
    required this.schedule,
    this.icon = Icons.groups_rounded,
  });
}
