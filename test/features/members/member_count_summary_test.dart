import 'package:churchsnap/features/members/models/member_count_summary.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MemberCountPolicy', () {
    test('counts an active visible congregation member', () {
      expect(
        MemberCountPolicy.countsInOverview(const <String, dynamic>{
          'role': 'member',
          'isActive': true,
          'directoryVisible': true,
        }),
        isTrue,
      );
    });

    test('excludes removed and inactive records', () {
      expect(
        MemberCountPolicy.countsInOverview(const <String, dynamic>{
          'role': 'member',
          'directoryVisible': false,
        }),
        isFalse,
      );

      expect(
        MemberCountPolicy.countsInOverview(const <String, dynamic>{
          'role': 'member',
          'isActive': false,
        }),
        isFalse,
      );
    });

    test('excludes protected staff and visitors', () {
      for (final role in <String>['admin', 'pastor', 'visitor']) {
        expect(
          MemberCountPolicy.countsInOverview(<String, dynamic>{
            'role': role,
            'isActive': true,
            'directoryVisible': true,
          }),
          isFalse,
        );
      }
    });

    test('recognizes only explicitly marked demo records', () {
      expect(
        MemberCountPolicy.isExplicitDemoRecord(const <String, dynamic>{
          'isDemo': true,
        }),
        isTrue,
      );
      expect(
        MemberCountPolicy.isExplicitDemoRecord(const <String, dynamic>{
          'dataOrigin': 'sample',
        }),
        isTrue,
      );
      expect(
        MemberCountPolicy.isExplicitDemoRecord(const <String, dynamic>{
          'displayName': 'Demo-looking Name',
        }),
        isFalse,
      );
    });
  });

  group('MemberCountSummary', () {
    test('calculates all count categories', () {
      final summary = MemberCountSummary.fromRecords(
        const <Map<String, dynamic>>[
          <String, dynamic>{
            'role': 'member',
            'isActive': true,
            'directoryVisible': true,
          },
          <String, dynamic>{
            'role': 'volunteer',
            'isActive': true,
            'directoryVisible': false,
          },
          <String, dynamic>{
            'role': 'member',
            'isActive': false,
            'directoryVisible': true,
          },
          <String, dynamic>{
            'role': 'admin',
            'isActive': true,
            'directoryVisible': true,
          },
          <String, dynamic>{
            'role': 'visitor',
            'isActive': true,
            'directoryVisible': true,
            'isSampleData': true,
          },
        ],
      );

      expect(summary.totalRecords, 5);
      expect(summary.overviewCount, 1);
      expect(summary.removedCount, 1);
      expect(summary.inactiveCount, 1);
      expect(summary.protectedCount, 1);
      expect(summary.visitorCount, 1);
      expect(summary.explicitDemoCount, 1);
    });
  });
}
