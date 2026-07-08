import 'package:cloud_firestore/cloud_firestore.dart';

class SmallGroup {
  final String id;
  final String name;
  final String description;
  final String leaderId;
  final String leaderName;
  final String location;
  final DateTime? meetingDate;
  final int capacity;
  final List<String> memberIds;
  final bool active;

  const SmallGroup({
    this.id = '',
    required this.name,
    required this.description,
    required this.leaderId,
    required this.leaderName,
    required this.location,
    this.meetingDate,
    this.capacity = 12,
    this.memberIds = const [],
    this.active = true,
  });

  factory SmallGroup.fromMap(String id, Map<String, dynamic> map) {
    return SmallGroup(
      id: id,
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      leaderId: map['leaderId'] ?? '',
      leaderName: map['leaderName'] ?? '',
      location: map['location'] ?? '',
      meetingDate: (map['meetingDate'] as Timestamp?)?.toDate(),
      capacity: map['capacity'] ?? 12,
      memberIds: List<String>.from(map['memberIds'] ?? []),
      active: map['active'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'leaderId': leaderId,
      'leaderName': leaderName,
      'location': location,
      'meetingDate': meetingDate == null
          ? null
          : Timestamp.fromDate(meetingDate!),
      'capacity': capacity,
      'memberIds': memberIds,
      'active': active,
    };
  }
}
