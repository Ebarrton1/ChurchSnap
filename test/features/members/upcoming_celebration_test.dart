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

    test('sorts the annual calendar in ascending date order', () {
      final calendar = UpcomingCelebrationCalculator.annualCalendar(
        profiles: <MemberCelebrationProfile>[
          MemberCelebrationProfile(
            memberId: 'later',
            memberName: 'Later Member',
            role: 'member',
            isActive: true,
            maritalStatus: '',
            dateOfBirth: DateTime(1990, 11, 20),
            weddingAnniversaryDate: null,
            birthdayReminderEnabled: true,
            anniversaryReminderEnabled: true,
          ),
          MemberCelebrationProfile(
            memberId: 'earlier',
            memberName: 'Earlier Member',
            role: 'member',
            isActive: true,
            maritalStatus: '',
            dateOfBirth: DateTime(1990, 8, 1),
            weddingAnniversaryDate: null,
            birthdayReminderEnabled: true,
            anniversaryReminderEnabled: true,
          ),
        ],
        now: DateTime(2026, 7, 15),
      );

      expect(calendar.map((item) => item.memberId), <String>[
        'earlier',
        'later',
      ]);
    });

    test('filters birthday and anniversary lists independently', () {
      final all = UpcomingCelebrationCalculator.annualCalendar(
        profiles: <MemberCelebrationProfile>[
          MemberCelebrationProfile(
            memberId: 'birthday',
            memberName: 'Birthday Member',
            role: 'member',
            isActive: true,
            maritalStatus: '',
            dateOfBirth: DateTime(1990, 8, 1),
            weddingAnniversaryDate: null,
            birthdayReminderEnabled: true,
            anniversaryReminderEnabled: true,
          ),
          MemberCelebrationProfile(
            memberId: 'anniversary',
            memberName: 'Anniversary Member',
            role: 'member',
            isActive: true,
            maritalStatus: 'married',
            dateOfBirth: null,
            weddingAnniversaryDate: DateTime(2010, 9, 1),
            birthdayReminderEnabled: true,
            anniversaryReminderEnabled: true,
          ),
        ],
        now: DateTime(2026, 7, 15),
      );

      final birthdays = UpcomingCelebrationCalculator.sortAndFilter(
        celebrations: all,
        filter: CelebrationFilter.birthdays,
        order: CelebrationDateOrder.soonestFirst,
      );
      final anniversaries = UpcomingCelebrationCalculator.sortAndFilter(
        celebrations: all,
        filter: CelebrationFilter.anniversaries,
        order: CelebrationDateOrder.soonestFirst,
      );

      expect(birthdays, hasLength(1));
      expect(birthdays.single.memberId, 'birthday');
      expect(anniversaries, hasLength(1));
      expect(anniversaries.single.memberId, 'anniversary');
    });

    test('supports latest-date-first ordering', () {
      final celebrations = <UpcomingCelebration>[
        UpcomingCelebration(
          memberId: 'early',
          memberName: 'Early',
          type: CelebrationType.birthday,
          originalDate: DateTime(1990, 8, 1),
          nextOccurrence: DateTime(2026, 8, 1),
          daysUntil: 17,
        ),
        UpcomingCelebration(
          memberId: 'late',
          memberName: 'Late',
          type: CelebrationType.birthday,
          originalDate: DateTime(1990, 11, 20),
          nextOccurrence: DateTime(2026, 11, 20),
          daysUntil: 128,
        ),
      ];

      final ordered = UpcomingCelebrationCalculator.sortAndFilter(
        celebrations: celebrations,
        filter: CelebrationFilter.all,
        order: CelebrationDateOrder.latestFirst,
      );

      expect(ordered.map((item) => item.memberId), <String>['late', 'early']);
    });
  });
}
