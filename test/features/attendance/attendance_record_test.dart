import 'package:churchsnap/features/attendance/models/attendance_record.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AttendanceRecord', () {
    test('parses canonical QR attendance fields', () {
      final checkedInAt = DateTime.utc(2026, 7, 19, 14, 30);
      final record =
          AttendanceRecord.fromMap('event-7_member-9', <String, dynamic>{
            'eventId': 'event-7',
            'memberId': 'member-9',
            'memberName': 'Ada Member',
            'checkInMethod': 'qr',
            'checkedInAt': Timestamp.fromDate(checkedInAt),
          }, eventTitle: 'Sunday Worship');

      expect(record.eventId, 'event-7');
      expect(record.memberId, 'member-9');
      expect(record.memberName, 'Ada Member');
      expect(record.checkInMethod, 'qr');
      expect(
        record.checkedInAt?.millisecondsSinceEpoch,
        checkedInAt.millisecondsSinceEpoch,
      );
      expect(record.eventTitle, 'Sunday Worship');
    });

    test('keeps reading legacy manual member aliases', () {
      final record = AttendanceRecord.fromMap(
        'legacy-1',
        const <String, dynamic>{
          'eventId': 'event-2',
          'userId': 'member-3',
          'displayName': 'Legacy Member',
        },
      );

      expect(record.memberId, 'member-3');
      expect(record.memberName, 'Legacy Member');
      expect(record.checkInMethod, 'manual');
    });
  });
}
