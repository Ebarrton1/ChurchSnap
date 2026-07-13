import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../core/utils/legacy_event_date_parser.dart';

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
    final when = map['when'] as String? ?? '';
    final storedStartDate = _dateFromValue(map['startDate']);

    return ChurchEvent(
      id: id,
      title: map['title'] as String? ?? '',
      when: when,
      location: map['location'] as String? ?? '',
      published: map['published'] as bool? ?? true,
      startDate: storedStartDate ?? LegacyEventDateParser.tryParse(when),
      endDate: _dateFromValue(map['endDate']),
      rsvpCount: (map['rsvpCount'] as num?)?.toInt() ?? 0,
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

  static DateTime? _dateFromValue(Object? value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return null;
  }
}
