import 'package:churchsnap/features/members/models/member_baptism_record.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MemberBaptismCalculator', () {
    test('includes eligible baptisms from the last 30 days', () {
      final recent = MemberBaptismCalculator.recent(
        records: <MemberBaptismRecord>[
          MemberBaptismRecord(
            memberId: 'today',
            memberName: 'Today Member',
            photoUrl: '',
            role: 'member',
            isActive: true,
            baptismDate: DateTime(2026, 7, 16),
          ),
          MemberBaptismRecord(
            memberId: 'boundary',
            memberName: 'Boundary Member',
            photoUrl: '',
            role: 'member',
            isActive: true,
            baptismDate: DateTime(2026, 6, 17),
          ),
          MemberBaptismRecord(
            memberId: 'too-old',
            memberName: 'Old Member',
            photoUrl: '',
            role: 'member',
            isActive: true,
            baptismDate: DateTime(2026, 6, 16),
          ),
        ],
        now: DateTime(2026, 7, 16),
      );

      expect(recent.map((record) => record.memberId), <String>[
        'today',
        'boundary',
      ]);
    });

    test('sorts the newest baptism first', () {
      final recent = MemberBaptismCalculator.recent(
        records: <MemberBaptismRecord>[
          MemberBaptismRecord(
            memberId: 'older',
            memberName: 'Older',
            photoUrl: '',
            role: 'member',
            isActive: true,
            baptismDate: DateTime(2026, 7, 1),
          ),
          MemberBaptismRecord(
            memberId: 'newer',
            memberName: 'Newer',
            photoUrl: '',
            role: 'member',
            isActive: true,
            baptismDate: DateTime(2026, 7, 15),
          ),
        ],
        now: DateTime(2026, 7, 16),
      );

      expect(recent.map((record) => record.memberId), <String>[
        'newer',
        'older',
      ]);
    });

    test('excludes visitors, inactive records, and future dates', () {
      final recent = MemberBaptismCalculator.recent(
        records: <MemberBaptismRecord>[
          MemberBaptismRecord(
            memberId: 'visitor',
            memberName: 'Visitor',
            photoUrl: '',
            role: 'visitor',
            isActive: true,
            baptismDate: DateTime(2026, 7, 10),
          ),
          MemberBaptismRecord(
            memberId: 'inactive',
            memberName: 'Inactive',
            photoUrl: '',
            role: 'member',
            isActive: false,
            baptismDate: DateTime(2026, 7, 10),
          ),
          MemberBaptismRecord(
            memberId: 'future',
            memberName: 'Future',
            photoUrl: '',
            role: 'member',
            isActive: true,
            baptismDate: DateTime(2026, 7, 17),
          ),
        ],
        now: DateTime(2026, 7, 16),
      );

      expect(recent, isEmpty);
    });

    test('calculates the number of days since baptism', () {
      final days = MemberBaptismCalculator.daysSinceBaptism(
        baptismDate: DateTime(2026, 7, 10),
        now: DateTime(2026, 7, 16),
      );

      expect(days, 6);
    });

    test('reads baptism dates from member private-profile records', () {
      final record = MemberBaptismRecord.fromRecords(
        memberId: 'member',
        member: <String, dynamic>{
          'displayName': 'Member Name',
          'photoUrl': 'https://example.com/photo.png',
          'role': 'member',
          'isActive': true,
        },
        privateProfile: <String, dynamic>{'baptismDate': '2026-07-01'},
      );

      expect(record.memberName, 'Member Name');
      expect(record.baptismDate, DateTime(2026, 7, 1));
      expect(record.isEligibleMember, isTrue);
    });
  });
}
