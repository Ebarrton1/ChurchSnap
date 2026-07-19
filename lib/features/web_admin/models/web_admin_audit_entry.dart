import 'package:cloud_firestore/cloud_firestore.dart';

class WebAdminAuditEntry {
  const WebAdminAuditEntry({
    required this.id,
    required this.action,
    required this.actorId,
    required this.actorRole,
    required this.targetMemberId,
    required this.targetDisplayName,
    required this.previousRole,
    required this.newRole,
    required this.createdAt,
  });

  factory WebAdminAuditEntry.fromMap({
    required String id,
    required Map<String, dynamic> data,
  }) {
    return WebAdminAuditEntry(
      id: id,
      action: _text(data, const ['action'], fallback: 'unknown_action'),
      actorId: _text(data, const [
        'actorId',
      ], fallback: 'Unknown administrator'),
      actorRole: _text(data, const ['actorRole'], fallback: 'Unknown role'),
      targetMemberId: _text(data, const [
        'targetMemberId',
      ], fallback: 'Unknown member'),
      targetDisplayName: _text(data, const [
        'targetDisplayName',
      ], fallback: 'Unnamed member'),
      previousRole: _text(data, const ['previousRole'], fallback: 'Unknown'),
      newRole: _text(data, const ['newRole'], fallback: 'Unknown'),
      createdAt: _dateTime(data['createdAt']),
    );
  }

  final String id;
  final String action;
  final String actorId;
  final String actorRole;
  final String targetMemberId;
  final String targetDisplayName;
  final String previousRole;
  final String newRole;
  final DateTime? createdAt;

  String get actionLabel {
    return switch (action) {
      'member_role_changed' => 'Member role changed',
      _ =>
        action
            .replaceAll('_', ' ')
            .split(' ')
            .where((word) => word.isNotEmpty)
            .map((word) => '${word[0].toUpperCase()}${word.substring(1)}')
            .join(' '),
    };
  }

  String get searchableText {
    return [
      action,
      actionLabel,
      actorId,
      actorRole,
      targetMemberId,
      targetDisplayName,
      previousRole,
      newRole,
    ].join(' ').toLowerCase();
  }

  static String _text(
    Map<String, dynamic> data,
    List<String> keys, {
    required String fallback,
  }) {
    for (final key in keys) {
      final value = data[key]?.toString().trim() ?? '';

      if (value.isNotEmpty) {
        return value;
      }
    }

    return fallback;
  }

  static DateTime? _dateTime(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    }

    if (value is DateTime) {
      return value;
    }

    if (value is String) {
      return DateTime.tryParse(value.trim());
    }

    return null;
  }
}
