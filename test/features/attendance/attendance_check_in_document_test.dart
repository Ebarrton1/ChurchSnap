import 'package:churchsnap/features/attendance/models/attendance_check_in_document.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AttendanceCheckInDocument', () {
    test('uses one deterministic event and member document ID', () {
      expect(
        AttendanceCheckInDocument.documentId(
          eventId: ' event-7 ',
          memberId: ' member-9 ',
        ),
        'event-7_member-9',
      );
    });

    test('writes canonical and compatibility member fields', () {
      final fields = AttendanceCheckInDocument.fields(
        churchId: ' church-1 ',
        eventId: 'event-7',
        memberId: 'member-9',
        memberName: ' Ada Member ',
        checkInMethod: ' qr ',
      );

      expect(fields['churchId'], 'church-1');
      expect(fields['eventId'], 'event-7');
      expect(fields['memberId'], 'member-9');
      expect(fields['userId'], 'member-9');
      expect(fields['memberName'], 'Ada Member');
      expect(fields['displayName'], 'Ada Member');
      expect(fields['checkInMethod'], 'qr');
      expect(fields['checkedInAt'], isA<FieldValue>());
    });

    test('rejects IDs containing a forward slash', () {
      expect(
        () => AttendanceCheckInDocument.documentId(
          eventId: 'events/sunday',
          memberId: 'member-9',
        ),
        throwsArgumentError,
      );
    });

    test('rejects empty event and member IDs', () {
      expect(
        () => AttendanceCheckInDocument.documentId(
          eventId: '',
          memberId: 'member-9',
        ),
        throwsArgumentError,
      );
      expect(
        () => AttendanceCheckInDocument.documentId(
          eventId: 'event-7',
          memberId: ' ',
        ),
        throwsArgumentError,
      );
    });
  });
}
