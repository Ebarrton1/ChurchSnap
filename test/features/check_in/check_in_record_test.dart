import 'package:churchsnap/features/check_in/models/check_in_record.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CheckInRecord', () {
    test('parses the legacy manual check-in field names', () {
      final record = CheckInRecord.fromMap('legacy-1', <String, dynamic>{
        'eventId': 'event-1',
        'userId': 'member-1',
        'displayName': 'Legacy Member',
        'checkInMethod': 'manual',
        'checkedInAt': Timestamp.fromDate(DateTime(2026, 7, 18, 9)),
      });

      expect(record.userId, 'member-1');
      expect(record.displayName, 'Legacy Member');
      expect(record.eventId, 'event-1');
      expect(record.checkInMethod, 'manual');
    });

    test('parses the QR attendance field names', () {
      final record = CheckInRecord.fromMap('qr-1', <String, dynamic>{
        'eventId': 'event-2',
        'memberId': 'member-2',
        'memberName': 'QR Member',
        'checkInMethod': 'qr',
        'checkedInAt': Timestamp.fromDate(DateTime(2026, 7, 18, 10)),
      });

      expect(record.userId, 'member-2');
      expect(record.displayName, 'QR Member');
      expect(record.checkInMethod, 'qr');
    });

    test('writes compatible legacy and QR member fields', () {
      const record = CheckInRecord(
        id: 'record-1',
        eventId: 'event-3',
        userId: 'member-3',
        displayName: 'Compatible Member',
        checkInMethod: 'manual',
      );

      final map = record.toMap();

      expect(map['userId'], 'member-3');
      expect(map['memberId'], 'member-3');
      expect(map['displayName'], 'Compatible Member');
      expect(map['memberName'], 'Compatible Member');
    });
  });
}
