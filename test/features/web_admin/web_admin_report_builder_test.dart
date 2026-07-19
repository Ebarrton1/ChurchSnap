import 'package:churchsnap/features/web_admin/models/web_admin_report_snapshot.dart';
import 'package:churchsnap/features/web_admin/services/web_admin_report_builder.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('WebAdminReportBuilder', () {
    test('summarizes member status and roles', () {
      final report = WebAdminReportBuilder.build(
        members: const [
          WebAdminReportSource(
            id: 'member-1',
            data: {
              'role': 'admin',
              'isActive': true,
              'profileNameComplete': true,
            },
          ),
          WebAdminReportSource(
            id: 'member-2',
            data: {
              'role': 'member',
              'isActive': false,
              'profileNameComplete': false,
            },
          ),
        ],
        prayerRequests: const [],
        events: const [],
        donations: const [],
        period: WebAdminReportPeriod.allTime,
        now: DateTime(2026, 7, 19),
      );

      expect(report.totalMembers, 2);
      expect(report.activeMembers, 1);
      expect(report.memberFollowUp, 1);
      expect(report.membersByRole, {'admin': 1, 'member': 1});
    });

    test('filters giving by period and excludes failed records', () {
      final now = DateTime(2026, 7, 19, 12);
      final report = WebAdminReportBuilder.build(
        members: const [],
        prayerRequests: const [],
        events: const [],
        donations: [
          WebAdminReportSource(
            id: 'recent',
            data: {
              'amount': 100,
              'currency': 'USD',
              'fundName': 'Tithe',
              'status': 'completed',
              'createdAt': now.subtract(const Duration(days: 5)),
            },
          ),
          WebAdminReportSource(
            id: 'old',
            data: {
              'amount': 50,
              'currency': 'USD',
              'fundName': 'Tithe',
              'status': 'completed',
              'createdAt': now.subtract(const Duration(days: 60)),
            },
          ),
          WebAdminReportSource(
            id: 'failed',
            data: {
              'amount': 75,
              'currency': 'USD',
              'fundName': 'Building Fund',
              'status': 'failed',
              'createdAt': now.subtract(const Duration(days: 2)),
            },
          ),
        ],
        period: WebAdminReportPeriod.thirtyDays,
        now: now,
      );

      expect(report.recordedDonationCount, 1);
      expect(report.givingByCurrency, {'USD': 100});
      expect(report.givingByFund, {'USD â€¢ Tithe': 100});
    });

    test('counts prayer workload and sorts upcoming events', () {
      final now = DateTime(2026, 7, 19, 12);
      final report = WebAdminReportBuilder.build(
        members: const [],
        prayerRequests: const [
          WebAdminReportSource(id: 'open', data: {'status': 'new'}),
          WebAdminReportSource(id: 'resolved', data: {'status': 'resolved'}),
        ],
        events: [
          WebAdminReportSource(
            id: 'later',
            data: {
              'title': 'Later Event',
              'startDate': now.add(const Duration(days: 20)),
            },
          ),
          WebAdminReportSource(
            id: 'sooner',
            data: {
              'title': 'Sooner Event',
              'startDate': now.add(const Duration(days: 3)),
            },
          ),
          WebAdminReportSource(
            id: 'too-far',
            data: {
              'title': 'Too Far',
              'startDate': now.add(const Duration(days: 40)),
            },
          ),
        ],
        donations: const [],
        period: WebAdminReportPeriod.allTime,
        now: now,
      );

      expect(report.openPrayerRequests, 1);
      expect(report.resolvedPrayerRequests, 1);
      expect(report.upcomingEvents.map((event) => event.id), [
        'sooner',
        'later',
      ]);
    });

    test('keeps different currencies separate', () {
      final report = WebAdminReportBuilder.build(
        members: const [],
        prayerRequests: const [],
        events: const [],
        donations: const [
          WebAdminReportSource(
            id: 'usd',
            data: {'amount': 100, 'currency': 'USD', 'fundName': 'Tithe'},
          ),
          WebAdminReportSource(
            id: 'jmd',
            data: {'amount': 5000, 'currency': 'JMD', 'fundName': 'Tithe'},
          ),
        ],
        period: WebAdminReportPeriod.allTime,
        now: DateTime(2026, 7, 19),
      );

      expect(report.givingByCurrency, {'JMD': 5000, 'USD': 100});
      expect(report.givingByFund.keys, {'JMD â€¢ Tithe', 'USD â€¢ Tithe'});
    });
  });
}
