import 'package:cloud_firestore/cloud_firestore.dart';

class CheckInRecord {
  const CheckInRecord({
    this.id = '',
    required this.eventId,
    required this.userId,
    required this.displayName,
    this.checkedInAt,
    this.checkInMethod = 'manual',
  });

  final String id;
  final String eventId;
  final String userId;
  final String displayName;
  final DateTime? checkedInAt;
  final String checkInMethod;

  factory CheckInRecord.fromMap(String id, Map<String, dynamic> data) {
    final checkedInAtValue = data['checkedInAt'];

    return CheckInRecord(
      id: id,
      eventId: (data['eventId']?.toString() ?? '').trim(),
      userId: (data['userId']?.toString() ?? data['memberId']?.toString() ?? '')
          .trim(),
      displayName:
          (data['displayName']?.toString() ??
                  data['memberName']?.toString() ??
                  '')
              .trim(),
      checkedInAt: checkedInAtValue is Timestamp
          ? checkedInAtValue.toDate()
          : checkedInAtValue is DateTime
          ? checkedInAtValue
          : null,
      checkInMethod: (data['checkInMethod']?.toString() ?? 'manual').trim(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'eventId': eventId.trim(),
      'userId': userId.trim(),
      'memberId': userId.trim(),
      'displayName': displayName.trim(),
      'memberName': displayName.trim(),
      'checkInMethod': checkInMethod.trim().isEmpty
          ? 'manual'
          : checkInMethod.trim(),
      'checkedInAt': checkedInAt == null
          ? FieldValue.serverTimestamp()
          : Timestamp.fromDate(checkedInAt!),
    };
  }
}
