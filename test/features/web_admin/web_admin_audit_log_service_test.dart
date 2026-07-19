import 'package:churchsnap/features/web_admin/models/web_admin_audit_entry.dart';
import 'package:churchsnap/features/web_admin/services/web_admin_audit_log_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('WebAdminAuditEntry', () {
    test('formats known and future action labels', () {
      const roleChange = WebAdminAuditEntry(
        id: '1',
        action: 'member_role_changed',
        actorId: 'admin',
        actorRole: 'admin',
        targetMemberId: 'member',
        targetDisplayName: 'Member',
        previousRole: 'member',
        newRole: 'volunteer',
        createdAt: null,
      );
      const futureAction = WebAdminAuditEntry(
        id: '2',
        action: 'member_directory_restored',
        actorId: 'admin',
        actorRole: 'admin',
        targetMemberId: 'member',
        targetDisplayName: 'Member',
        previousRole: '',
        newRole: '',
        createdAt: null,
      );

      expect(roleChange.actionLabel, 'Member role changed');
      expect(futureAction.actionLabel, 'Member Directory Restored');
    });
  });

  group('WebAdminAuditLogService helpers', () {
    final now = DateTime(2026, 7, 19, 12);
    final entries = <WebAdminAuditEntry>[
      WebAdminAuditEntry(
        id: 'recent',
        action: 'member_role_changed',
        actorId: 'admin-1',
        actorRole: 'admin',
        targetMemberId: 'member-1',
        targetDisplayName: 'Jordan Member',
        previousRole: 'member',
        newRole: 'volunteer',
        createdAt: now.subtract(const Duration(days: 2)),
      ),
      WebAdminAuditEntry(
        id: 'old',
        action: 'member_role_changed',
        actorId: 'admin-2',
        actorRole: 'admin',
        targetMemberId: 'member-2',
        targetDisplayName: 'Taylor Member',
        previousRole: 'volunteer',
        newRole: 'member',
        createdAt: now.subtract(const Duration(days: 40)),
      ),
    ];

    test('filters by search and period', () {
      final filtered = WebAdminAuditLogService.filterEntries(
        entries: entries,
        search: 'Jordan',
        action: null,
        period: WebAdminAuditPeriod.thirtyDays,
        now: now,
      );

      expect(filtered.map((entry) => entry.id), ['recent']);
    });

    test('summarizes actors, targets, and actions', () {
      expect(
        WebAdminAuditLogService.countAction(entries, 'member_role_changed'),
        2,
      );
      expect(WebAdminAuditLogService.uniqueActorCount(entries), 2);
      expect(WebAdminAuditLogService.uniqueTargetCount(entries), 2);
    });
  });
}
