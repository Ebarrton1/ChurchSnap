import 'package:cloud_firestore/cloud_firestore.dart';

class AttendanceCheckInDocument {
  const AttendanceCheckInDocument._();

  static String documentId({
    required String eventId,
    required String memberId,
  }) {
    final cleanEventId = _requiredId(eventId, 'eventId', 'An event ID');
    final cleanMemberId = _requiredId(memberId, 'memberId', 'A member ID');

    return '${cleanEventId}_$cleanMemberId';
  }

  static Map<String, dynamic> fields({
    required String eventId,
    required String memberId,
    required String memberName,
    required String checkInMethod,
    String churchId = '',
    DateTime? checkedInAt,
  }) {
    final cleanEventId = _requiredId(eventId, 'eventId', 'An event ID');
    final cleanMemberId = _requiredId(memberId, 'memberId', 'A member ID');
    final cleanMemberName = memberName.trim().isEmpty
        ? 'ChurchSnap Member'
        : memberName.trim();
    final cleanMethod = checkInMethod.trim().isEmpty
        ? 'manual'
        : checkInMethod.trim();

    return <String, dynamic>{
      if (churchId.trim().isNotEmpty) 'churchId': churchId.trim(),
      'eventId': cleanEventId,
      'memberId': cleanMemberId,
      'userId': cleanMemberId,
      'memberName': cleanMemberName,
      'displayName': cleanMemberName,
      'checkInMethod': cleanMethod,
      'checkedInAt': checkedInAt == null
          ? FieldValue.serverTimestamp()
          : Timestamp.fromDate(checkedInAt),
    };
  }

  static String _requiredId(
    String value,
    String argumentName,
    String description,
  ) {
    final cleanValue = value.trim();

    if (cleanValue.isEmpty) {
      throw ArgumentError.value(
        value,
        argumentName,
        '$description is required.',
      );
    }

    if (cleanValue.contains('/')) {
      throw ArgumentError.value(
        value,
        argumentName,
        '$description cannot contain a forward slash.',
      );
    }

    return cleanValue;
  }
}
