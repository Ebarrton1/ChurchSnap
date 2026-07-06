import 'package:flutter/material.dart';

class ChurchEvent {
  final String title;
  final String when;
  final String location;
  final IconData icon;

  const ChurchEvent({
    required this.title,
    required this.when,
    required this.location,
    this.icon = Icons.event_rounded,
  });
}
