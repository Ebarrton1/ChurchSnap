import 'package:churchsnap/features/members/models/member_count_summary.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MemberCountPolicy', () {
    test('counts a member unless explicitly removed', () {
      expect(
        MemberCountPolicy.countsInOverview(const <String, dynamic>{
          'role': 'member',
          'directoryVisible': true,
        }),
        isTrue,
      );

      expect(
        MemberCountPolicy.countsInOverview(const <String, dynamic>{
          'role': 'admin',
          'isActive': false,
        }),
        isTrue,
      );
    });

    test('excludes only directory-removed members', () {
      expect(
        MemberCountPolicy.countsInOverview(const <String, dynamic>{
          'role': 'member',
          'directoryVisible': false,
        }),
        isFalse,
      );
    });

    test('older records remain counted when visibility is missing', () {
      expect(
        MemberCountPolicy.countsInOverview(const <String, dynamic>{
          'displayName': 'Existing Member',
        }),
        isTrue,
      );
    });
  });

  test('summary subtracts only removed records', () {
    final summary = MemberCountSummary.fromRecords(const <Map<String, dynamic>>[
      <String, dynamic>{'role': 'member', 'directoryVisible': true},
      <String, dynamic>{'role': 'member', 'directoryVisible': false},
      <String, dynamic>{'role': 'admin', 'isActive': false},
    ]);

    expect(summary.totalRecords, 3);
    expect(summary.overviewCount, 2);
    expect(summary.removedCount, 1);
  });
}
