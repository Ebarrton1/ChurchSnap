import 'package:flutter/material.dart';

class ChurchEvent {
  final String id;
  final String title;
  final String when;
  final String location;
  final IconData icon;
  final bool published;
  final DateTime? startDate;

  const ChurchEvent({
    this.id = '',
    required this.title,
    required this.when,
    required this.location,
    this.icon = Icons.event_rounded,
    this.published = true,
    this.startDate,
  });

  factory ChurchEvent.fromMap(String id, Map<String, dynamic> map) {
    final startDate = map['startDate'] == null
        ? null
        : map['startDate'].toDate() as DateTime;

    return ChurchEvent(
      id: id,
      title: map['title'] as String? ?? '',
      when: map['when'] as String? ?? '',
      location: map['location'] as String? ?? '',
      published: map['published'] as bool? ?? true,
      startDate: startDate,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'when': when,
      'location': location,
      'published': published,
      'startDate': startDate,
    };
  }
}
