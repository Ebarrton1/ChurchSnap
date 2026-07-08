import 'package:cloud_firestore/cloud_firestore.dart';

class CheckInRecord {
  final String id;
  final String eventId;
  final String userId;
  final String displayName;
  final DateTime? checkedInAt;

  const CheckInRecord({
    this.id = '',
    required this.eventId,
    required this.userId,
    required this.displayName,
    this.checkedInAt,
  });

  factory CheckInRecord.fromMap(String id, Map<String, dynamic> data) {
    return CheckInRecord(
      id: id,
      eventId: data['eventId'] as String? ?? '',
      userId: data['userId'] as String? ?? '',
      displayName: data['displayName'] as String? ?? '',
      checkedInAt: (data['checkedInAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'eventId': eventId,
      'userId': userId,
      'displayName': displayName,
      'checkedInAt': checkedInAt == null
          ? FieldValue.serverTimestamp()
          : Timestamp.fromDate(checkedInAt!),
    };
  }
}
