import 'package:cloud_firestore/cloud_firestore.dart';

import 'worship_service_entry.dart';

class WorshipSettings {
  const WorshipSettings({
    this.sectionTitle = 'Sabbath & Sunday Worship',
    this.showSection = true,
    this.leaderText = 'Pastor and Worship Team',
    this.buttonText = 'View Worship Details',
    this.services = defaultServices,
    this.updatedAt,
  });

  final String sectionTitle;
  final bool showSection;
  final String leaderText;
  final String buttonText;
  final List<WorshipServiceEntry> services;
  final DateTime? updatedAt;

  static const List<WorshipServiceEntry> defaultServices =
      <WorshipServiceEntry>[
        WorshipServiceEntry(
          id: 'sabbath',
          title: 'Sabbath Worship',
          dayLabel: 'Saturday',
          time: '11:00 AM',
          location: 'Main Sanctuary',
          order: 0,
        ),
        WorshipServiceEntry(
          id: 'sunday',
          title: 'Sunday Worship',
          dayLabel: 'Sunday',
          time: '10:00 AM',
          location: 'Main Sanctuary',
          order: 1,
        ),
      ];

  List<WorshipServiceEntry> get visibleServices {
    final result = services.where((service) => service.enabled).toList()
      ..sort((first, second) => first.order.compareTo(second.order));

    return result;
  }

  String get scheduleSummary {
    return visibleServices
        .map((service) {
          final day = service.dayLabel.trim();
          final time = service.time.trim();

          if (day.isEmpty) {
            return time;
          }

          if (time.isEmpty) {
            return day;
          }

          return '$day at $time';
        })
        .where((value) => value.isNotEmpty)
        .join(' | ');
  }

  factory WorshipSettings.fromMap(Map<String, dynamic>? map) {
    if (map == null || map.isEmpty) {
      return const WorshipSettings();
    }

    final rawServices = map['services'] as List<dynamic>? ?? const [];

    final services = rawServices
        .whereType<Map>()
        .map(
          (service) =>
              WorshipServiceEntry.fromMap(Map<String, dynamic>.from(service)),
        )
        .toList();

    return WorshipSettings(
      sectionTitle:
          map['sectionTitle'] as String? ?? 'Sabbath & Sunday Worship',
      showSection: map['showSection'] as bool? ?? true,
      leaderText: map['leaderText'] as String? ?? 'Pastor and Worship Team',
      buttonText: map['buttonText'] as String? ?? 'View Worship Details',
      services: services.isEmpty ? defaultServices : services,
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'sectionTitle': sectionTitle.trim(),
      'showSection': showSection,
      'leaderText': leaderText.trim(),
      'buttonText': buttonText.trim(),
      'services': services.map((service) => service.toMap()).toList(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  WorshipSettings copyWith({
    String? sectionTitle,
    bool? showSection,
    String? leaderText,
    String? buttonText,
    List<WorshipServiceEntry>? services,
    DateTime? updatedAt,
  }) {
    return WorshipSettings(
      sectionTitle: sectionTitle ?? this.sectionTitle,
      showSection: showSection ?? this.showSection,
      leaderText: leaderText ?? this.leaderText,
      buttonText: buttonText ?? this.buttonText,
      services: services ?? this.services,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
