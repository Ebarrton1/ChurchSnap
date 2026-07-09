import 'package:cloud_firestore/cloud_firestore.dart';

class AppNotification {
  final String id;
  final String title;
  final String body;
  final String type;
  final String targetRole;
  final DateTime? createdAt;
  final bool sent;

  const AppNotification({
    this.id = '',
    required this.title,
    required this.body,
    this.type = 'announcement',
    this.targetRole = 'all',
    this.createdAt,
    this.sent = false,
  });

  factory AppNotification.fromMap(String id, Map<String, dynamic> map) {
    return AppNotification(
      id: id,
      title: map['title'] ?? '',
      body: map['body'] ?? '',
      type: map['type'] ?? 'announcement',
      targetRole: map['targetRole'] ?? 'all',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
      sent: map['sent'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'body': body,
      'type': type,
      'targetRole': targetRole,
      'createdAt': createdAt == null
          ? FieldValue.serverTimestamp()
          : Timestamp.fromDate(createdAt!),
      'sent': sent,
    };
  }
}
