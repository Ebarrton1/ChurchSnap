import 'package:churchsnap/features/members/models/member_demographics_summary.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MemberDemographicsSummary', () {
    test('excludes visitors and inactive records', () {
      final summary = MemberDemographicsSummary.fromRecords(
        members: <String, Map<String, dynamic>>{
          'active-member': <String, dynamic>{
            'role': 'member',
            'isActive': true,
          },
          'visitor': <String, dynamic>{'role': 'visitor', 'isActive': true},
          'inactive-member': <String, dynamic>{
            'role': 'member',
            'isActive': false,
          },
        },
        privateProfiles: const <String, Map<String, dynamic>>{},
        now: DateTime(2026, 7, 15),
      );

      expect(summary.totalMembers, 1);
      expect(summary.excludedVisitors, 1);
      expect(summary.inactiveRecords, 1);
    });

    test('tallies age, gender, and marital status', () {
      final summary = MemberDemographicsSummary.fromRecords(
        members: <String, Map<String, dynamic>>{
          'adult': <String, dynamic>{'role': 'member', 'isActive': true},
          'teen': <String, dynamic>{'role': 'member', 'isActive': true},
          'child': <String, dynamic>{'role': 'member', 'isActive': true},
          'senior': <String, dynamic>{'role': 'pastor', 'isActive': true},
        },
        privateProfiles: <String, Map<String, dynamic>>{
          'adult': <String, dynamic>{
            'dateOfBirth': DateTime(1996, 1, 10),
            'gender': 'Female',
            'maritalStatus': 'Married',
          },
          'teen': <String, dynamic>{
            'dateOfBirth': DateTime(2010, 8, 1),
            'gender': 'Male',
            'maritalStatus': 'Single',
          },
          'child': <String, dynamic>{
            'dateOfBirth': DateTime(2018, 3, 20),
            'gender': 'Female',
            'maritalStatus': 'Single',
          },
          'senior': <String, dynamic>{
            'dateOfBirth': DateTime(1950, 5, 5),
            'gender': 'Male',
            'maritalStatus': 'Widowed',
          },
        },
        now: DateTime(2026, 7, 15),
      );

      expect(summary.totalMembers, 4);
      expect(summary.adults, 2);
      expect(summary.childrenAndYouth, 2);
      expect(summary.unknownAge, 0);
      expect(summary.completeProfiles, 4);
      expect(summary.genderCounts['Male'], 2);
      expect(summary.genderCounts['Female'], 2);
      expect(summary.maritalStatusCounts['Single'], 2);
      expect(summary.maritalStatusCounts['Married'], 1);
      expect(summary.maritalStatusCounts['Widowed'], 1);
      expect(summary.ageGroupCounts['Children (0-12)'], 1);
      expect(summary.ageGroupCounts['Teens (13-17)'], 1);
      expect(summary.ageGroupCounts['Young Adults (18-35)'], 1);
      expect(summary.ageGroupCounts['Seniors (65+)'], 1);
    });

    test('reports missing demographic information', () {
      final summary = MemberDemographicsSummary.fromRecords(
        members: <String, Map<String, dynamic>>{
          'member-one': <String, dynamic>{'role': 'member'},
          'member-two': <String, dynamic>{'role': 'admin'},
        },
        privateProfiles: <String, Map<String, dynamic>>{
          'member-one': <String, dynamic>{
            'gender': 'Prefer not to say',
            'maritalStatus': 'Single',
          },
          'member-two': <String, dynamic>{
            'dateOfBirth': DateTime(1980, 1, 1),
            'gender': 'Female',
          },
        },
        now: DateTime(2026, 7, 15),
      );

      expect(summary.totalMembers, 2);
      expect(summary.completeProfiles, 0);
      expect(summary.missingAnyDemographic, 2);
      expect(summary.missingDateOfBirth, 1);
      expect(summary.missingGender, 1);
      expect(summary.missingMaritalStatus, 1);
      expect(summary.unknownAge, 1);
      expect(summary.genderCounts['Not provided'], 1);
      expect(summary.maritalStatusCounts['Not provided'], 1);
    });

    test('calculates age after checking whether birthday occurred', () {
      final summary = MemberDemographicsSummary.fromRecords(
        members: <String, Map<String, dynamic>>{
          'before-birthday': <String, dynamic>{'role': 'member'},
          'after-birthday': <String, dynamic>{'role': 'member'},
        },
        privateProfiles: <String, Map<String, dynamic>>{
          'before-birthday': <String, dynamic>{
            'dateOfBirth': DateTime(2008, 7, 16),
            'gender': 'Male',
            'maritalStatus': 'Single',
          },
          'after-birthday': <String, dynamic>{
            'dateOfBirth': DateTime(2008, 7, 14),
            'gender': 'Female',
            'maritalStatus': 'Single',
          },
        },
        now: DateTime(2026, 7, 15),
      );

      expect(summary.childrenAndYouth, 1);
      expect(summary.adults, 1);
      expect(summary.ageGroupCounts['Teens (13-17)'], 1);
      expect(summary.ageGroupCounts['Young Adults (18-35)'], 1);
    });
  });
}
