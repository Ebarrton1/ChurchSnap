import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/auth/app_roles.dart';

class AppNotification {
  static const String allAudience = 'all';

  final String id;
  final String title;
  final String body;
  final String type;
  final String targetRole;
  final DateTime? createdAt;
  final DateTime? sentAt;
  final bool sent;
  final String deliveryStatus;
  final int successCount;
  final int failureCount;
  final int recipientCount;
  final String sendResult;

  const AppNotification({
    this.id = '',
    required this.title,
    required this.body,
    this.type = 'announcement',
    this.targetRole = allAudience,
    this.createdAt,
    this.sentAt,
    this.sent = false,
    this.deliveryStatus = 'pending',
    this.successCount = 0,
    this.failureCount = 0,
    this.recipientCount = 0,
    this.sendResult = '',
  });

  static bool isValidAudience(String audience) {
    return audience == allAudience || AppRoles.isValid(audience);
  }

  String get audienceLabel {
    if (targetRole == allAudience) {
      return 'All active members';
    }

    return AppRoles.label(targetRole);
  }

  String get deliveryLabel {
    return switch (deliveryStatus) {
      'sending' => 'Sending',
      'sent' => 'Sent',
      'partial' => 'Partially sent',
      'failed' => 'Failed',
      'noRecipients' => 'No recipients',
      _ => 'Pending',
    };
  }

  factory AppNotification.fromMap(String id, Map<String, dynamic> map) {
    return AppNotification(
      id: id,
      title: map['title'] as String? ?? '',
      body: map['body'] as String? ?? '',
      type: map['type'] as String? ?? 'announcement',
      targetRole: map['targetRole'] as String? ?? allAudience,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
      sentAt: (map['sentAt'] as Timestamp?)?.toDate(),
      sent: map['sent'] as bool? ?? false,
      deliveryStatus: map['deliveryStatus'] as String? ?? 'pending',
      successCount: map['successCount'] as int? ?? 0,
      failureCount: map['failureCount'] as int? ?? 0,
      recipientCount: map['recipientCount'] as int? ?? 0,
      sendResult: map['sendResult'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    final normalizedAudience = isValidAudience(targetRole)
        ? targetRole
        : allAudience;

    return {
      'title': title.trim(),
      'body': body.trim(),
      'type': type,
      'targetRole': normalizedAudience,
      'createdAt': createdAt == null
          ? FieldValue.serverTimestamp()
          : Timestamp.fromDate(createdAt!),
      'sent': false,
      'deliveryStatus': 'pending',
      'successCount': 0,
      'failureCount': 0,
      'recipientCount': 0,
      'sendResult': '',
    };
  }
}
