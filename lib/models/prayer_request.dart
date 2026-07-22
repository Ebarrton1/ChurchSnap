import 'package:cloud_firestore/cloud_firestore.dart';

class PrayerRequest {
  final String id;
  final String createdByUid;
  final String name;
  final String request;
  final bool isPrivate;
  final bool published;
  final DateTime? createdAt;

  const PrayerRequest({
    this.id = '',
    this.createdByUid = '',
    required this.name,
    required this.request,
    this.isPrivate = false,
    this.published = true,
    this.createdAt,
  });

  factory PrayerRequest.fromMap(String id, Map<String, dynamic> data) {
    return PrayerRequest(
      id: id,
      createdByUid: data['createdByUid'] as String? ?? '',
      name: data['name'] ?? 'Anonymous',
      request: data['request'] ?? '',
      isPrivate: data['isPrivate'] ?? false,
      published: data['published'] ?? true,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'createdByUid': createdByUid,
      'name': name,
      'request': request,
      'isPrivate': isPrivate,
      'published': published,
      'createdAt': createdAt == null
          ? FieldValue.serverTimestamp()
          : Timestamp.fromDate(createdAt!),
    };
  }
}
