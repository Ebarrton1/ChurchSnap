class WorshipServiceEntry {
  const WorshipServiceEntry({
    required this.id,
    required this.title,
    required this.dayLabel,
    required this.time,
    this.location = '',
    this.description = '',
    this.enabled = true,
    this.order = 0,
  });

  final String id;
  final String title;
  final String dayLabel;
  final String time;
  final String location;
  final String description;
  final bool enabled;
  final int order;

  factory WorshipServiceEntry.fromMap(Map<String, dynamic> map) {
    return WorshipServiceEntry(
      id: map['id'] as String? ?? '',
      title: map['title'] as String? ?? '',
      dayLabel: map['dayLabel'] as String? ?? '',
      time: map['time'] as String? ?? '',
      location: map['location'] as String? ?? '',
      description: map['description'] as String? ?? '',
      enabled: map['enabled'] as bool? ?? true,
      order: (map['order'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'title': title,
      'dayLabel': dayLabel,
      'time': time,
      'location': location,
      'description': description,
      'enabled': enabled,
      'order': order,
    };
  }

  WorshipServiceEntry copyWith({
    String? id,
    String? title,
    String? dayLabel,
    String? time,
    String? location,
    String? description,
    bool? enabled,
    int? order,
  }) {
    return WorshipServiceEntry(
      id: id ?? this.id,
      title: title ?? this.title,
      dayLabel: dayLabel ?? this.dayLabel,
      time: time ?? this.time,
      location: location ?? this.location,
      description: description ?? this.description,
      enabled: enabled ?? this.enabled,
      order: order ?? this.order,
    );
  }
}
