import 'package:churchsnap/features/members/models/upcoming_celebration.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('UpcomingCelebrationCalculator', () {
    test('includes birthdays and married anniversaries within 7 days', () {
      final results = UpcomingCelebrationCalculator.calculate(
        profiles: <MemberCelebrationProfile>[
          MemberCelebrationProfile(
            memberId: 'birthday-member',
            memberName: 'Birthday Member',
            role: 'member',
            isActive: true,
            maritalStatus: 'single',
            dateOfBirth: DateTime(1980, 7, 18),
            weddingAnniversaryDate: null,
            birthdayReminderEnabled: true,
            anniversaryReminderEnabled: true,
          ),
          MemberCelebrationProfile(
            memberId: 'married-member',
            memberName: 'Married Member',
            role: 'member',
            isActive: true,
            maritalStatus: 'married',
            dateOfBirth: null,
            weddingAnniversaryDate: DateTime(2010, 7, 22),
            birthdayReminderEnabled: true,
            anniversaryReminderEnabled: true,
          ),
        ],
        now: DateTime(2026, 7, 15),
      );

      expect(results, hasLength(2));
      expect(results[0].type, CelebrationType.birthday);
      expect(results[0].daysUntil, 3);
      expect(results[1].type, CelebrationType.weddingAnniversary);
      expect(results[1].daysUntil, 7);
    });

    test('excludes visitors, inactive members, and disabled reminders', () {
      final results = UpcomingCelebrationCalculator.calculate(
        profiles: <MemberCelebrationProfile>[
          MemberCelebrationProfile(
            memberId: 'visitor',
            memberName: 'Visitor',
            role: 'visitor',
            isActive: true,
            maritalStatus: '',
            dateOfBirth: DateTime(1990, 7, 16),
            weddingAnniversaryDate: null,
            birthdayReminderEnabled: true,
            anniversaryReminderEnabled: true,
          ),
          MemberCelebrationProfile(
            memberId: 'inactive',
            memberName: 'Inactive',
            role: 'member',
            isActive: false,
            maritalStatus: '',
            dateOfBirth: DateTime(1990, 7, 16),
            weddingAnniversaryDate: null,
            birthdayReminderEnabled: true,
            anniversaryReminderEnabled: true,
          ),
          MemberCelebrationProfile(
            memberId: 'disabled',
            memberName: 'Disabled',
            role: 'member',
            isActive: true,
            maritalStatus: '',
            dateOfBirth: DateTime(1990, 7, 16),
            weddingAnniversaryDate: null,
            birthdayReminderEnabled: false,
            anniversaryReminderEnabled: true,
          ),
        ],
        now: DateTime(2026, 7, 15),
      );

      expect(results, isEmpty);
    });

    test('handles a December-to-January reminder window', () {
      final results = UpcomingCelebrationCalculator.calculate(
        profiles: <MemberCelebrationProfile>[
          MemberCelebrationProfile(
            memberId: 'new-year-member',
            memberName: 'New Year Member',
            role: 'member',
            isActive: true,
            maritalStatus: '',
            dateOfBirth: DateTime(1985, 1, 2),
            weddingAnniversaryDate: null,
            birthdayReminderEnabled: true,
            anniversaryReminderEnabled: true,
          ),
        ],
        now: DateTime(2026, 12, 29),
      );

      expect(results, hasLength(1));
      expect(results.single.daysUntil, 4);
      expect(results.single.nextOccurrence, DateTime(2027, 1, 2));
    });

    test('uses February 28 for leap-day birthdays in non-leap years', () {
      final results = UpcomingCelebrationCalculator.calculate(
        profiles: <MemberCelebrationProfile>[
          MemberCelebrationProfile(
            memberId: 'leap-member',
            memberName: 'Leap Member',
            role: 'member',
            isActive: true,
            maritalStatus: '',
            dateOfBirth: DateTime(2000, 2, 29),
            weddingAnniversaryDate: null,
            birthdayReminderEnabled: true,
            anniversaryReminderEnabled: true,
          ),
        ],
        now: DateTime(2027, 2, 25),
      );

      expect(results, hasLength(1));
      expect(results.single.nextOccurrence, DateTime(2027, 2, 28));
      expect(results.single.daysUntil, 3);
    });

    test('does not report anniversaries for non-married profiles', () {
      final results = UpcomingCelebrationCalculator.calculate(
        profiles: <MemberCelebrationProfile>[
          MemberCelebrationProfile(
            memberId: 'single-member',
            memberName: 'Single Member',
            role: 'member',
            isActive: true,
            maritalStatus: 'single',
            dateOfBirth: null,
            weddingAnniversaryDate: DateTime(2020, 7, 16),
            birthdayReminderEnabled: true,
            anniversaryReminderEnabled: true,
          ),
        ],
        now: DateTime(2026, 7, 15),
      );

      expect(results, isEmpty);
    });

    test('defaults missing reminder fields to enabled', () {
      final profile = MemberCelebrationProfile.fromRecords(
        memberId: 'member',
        member: <String, dynamic>{'displayName': 'Member', 'role': 'member'},
        privateProfile: <String, dynamic>{'dateOfBirth': DateTime(1990, 7, 16)},
      );

      expect(profile.birthdayReminderEnabled, isTrue);
      expect(profile.anniversaryReminderEnabled, isTrue);
    });
  });
}
