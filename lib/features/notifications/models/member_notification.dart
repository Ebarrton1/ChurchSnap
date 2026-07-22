import 'package:cloud_firestore/cloud_firestore.dart';

class MemberNotification {
  const MemberNotification({
    required this.id,
    required this.sourceNotificationId,
    required this.title,
    required this.body,
    required this.type,
    required this.targetRole,
    required this.createdAt,
    required this.isRead,
    this.readAt,
  });

  final String id;
  final String sourceNotificationId;
  final String title;
  final String body;
  final String type;
  final String targetRole;
  final DateTime createdAt;
  final bool isRead;
  final DateTime? readAt;

  factory MemberNotification.fromDocument(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data() ?? const <String, dynamic>{};

    return MemberNotification(
      id: document.id,
      sourceNotificationId:
          (data['sourceNotificationId'] as String?)?.trim() ?? document.id,
      title: (data['title'] as String?)?.trim() ?? 'ChurchSnap',
      body: (data['body'] as String?)?.trim() ?? '',
      type: (data['type'] as String?)?.trim() ?? 'announcement',
      targetRole: (data['targetRole'] as String?)?.trim() ?? 'all',
      createdAt: _dateTimeFrom(data['createdAt']),
      isRead: data['read'] == true,
      readAt: _nullableDateTimeFrom(data['readAt']),
    );
  }

  static DateTime _dateTimeFrom(Object? value) {
    return _nullableDateTimeFrom(value) ??
        DateTime.fromMillisecondsSinceEpoch(0);
  }

  static DateTime? _nullableDateTimeFrom(Object? value) {
    if (value is Timestamp) {
      return value.toDate();
    }

    if (value is DateTime) {
      return value;
    }

    if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(value);
    }

    return null;
  }
}
