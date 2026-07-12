import 'package:cloud_firestore/cloud_firestore.dart';

class CheckInRecord {
  const CheckInRecord({
    this.id = '',
    required this.eventId,
    required this.userId,
    required this.displayName,
    this.checkedInAt,
  });

  final String id;
  final String eventId;
  final String userId;
  final String displayName;
  final DateTime? checkedInAt;

  factory CheckInRecord.fromMap(String id, Map<String, dynamic> data) {
    final storedUserId =
        data['memberId'] as String? ?? data['userId'] as String? ?? '';

    final storedDisplayName =
        data['memberName'] as String? ??
        data['displayName'] as String? ??
        'ChurchSnap Member';

    final checkedInAtValue = data['checkedInAt'];

    return CheckInRecord(
      id: id,
      eventId: data['eventId'] as String? ?? '',
      userId: storedUserId,
      displayName: storedDisplayName,
      checkedInAt: checkedInAtValue is Timestamp
          ? checkedInAtValue.toDate()
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'eventId': eventId,

      // Canonical attendance fields.
      'memberId': userId,
      'memberName': displayName,
      'checkInMethod': 'manual',

      // Legacy compatibility fields.
      'userId': userId,
      'displayName': displayName,

      'checkedInAt': checkedInAt == null
          ? FieldValue.serverTimestamp()
          : Timestamp.fromDate(checkedInAt!),
    };
  }
}
