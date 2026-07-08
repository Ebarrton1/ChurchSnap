import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ChurchEvent {
  final String id;
  final String title;
  final String when;
  final String location;
  final IconData icon;
  final bool published;
  final DateTime? startDate;
  final DateTime? endDate;
  final int rsvpCount;
  final List<String> attendeeIds;

  const ChurchEvent({
    this.id = '',
    required this.title,
    required this.when,
    required this.location,
    this.icon = Icons.event_rounded,
    this.published = true,
    this.startDate,
    this.endDate,
    this.rsvpCount = 0,
    this.attendeeIds = const [],
  });

  factory ChurchEvent.fromMap(String id, Map<String, dynamic> map) {
    return ChurchEvent(
      id: id,
      title: map['title'] as String? ?? '',
      when: map['when'] as String? ?? '',
      location: map['location'] as String? ?? '',
      published: map['published'] as bool? ?? true,
      startDate: (map['startDate'] as Timestamp?)?.toDate(),
      endDate: (map['endDate'] as Timestamp?)?.toDate(),
      rsvpCount: map['rsvpCount'] as int? ?? 0,
      attendeeIds: List<String>.from(map['attendeeIds'] ?? const []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'when': when,
      'location': location,
      'published': published,
      'startDate': startDate == null ? null : Timestamp.fromDate(startDate!),
      'endDate': endDate == null ? null : Timestamp.fromDate(endDate!),
      'rsvpCount': rsvpCount,
      'attendeeIds': attendeeIds,
    };
  }
}
