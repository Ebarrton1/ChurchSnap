import 'package:cloud_firestore/cloud_firestore.dart';

class AttendanceRecord {
  const AttendanceRecord({
    required this.id,
    required this.eventId,
    required this.eventTitle,
    required this.memberId,
    required this.memberName,
    required this.checkInMethod,
    this.checkedInAt,
  });

  final String id;
  final String eventId;
  final String eventTitle;
  final String memberId;
  final String memberName;
  final String checkInMethod;
  final DateTime? checkedInAt;

  factory AttendanceRecord.fromMap(
    String id,
    Map<String, dynamic> map, {
    String eventTitle = '',
  }) {
    final checkedInAtValue = map['checkedInAt'];

    return AttendanceRecord(
      id: id,
      eventId: map['eventId'] as String? ?? '',
      eventTitle: eventTitle,
      memberId: map['memberId'] as String? ?? '',
      memberName: map['memberName'] as String? ?? '',
      checkInMethod: map['checkInMethod'] as String? ?? 'manual',
      checkedInAt: checkedInAtValue is Timestamp
          ? checkedInAtValue.toDate()
          : null,
    );
  }
}
