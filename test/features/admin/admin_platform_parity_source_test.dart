import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('web dashboard exposes the complete shared admin dashboard', () {
    final source = File(
      'lib/features/web_admin/screens/churchsnap_web_admin_shell.dart',
    ).readAsStringSync();

    expect(
      source,
      contains("import '../../../screens/admin/admin_dashboard_screen.dart';"),
    );
    expect(source, contains('AdminDashboardScreen(churchId: _churchId)'));
    expect(source, contains("label: Text('All Tools')"));
    expect(source, contains("label: 'All Tools'"));
  });

  test('phone dashboard exposes web operations and governance tools', () {
    final source = File(
      'lib/screens/admin/admin_dashboard_screen.dart',
    ).readAsStringSync();

    expect(source, contains("title: 'Action Center'"));
    expect(source, contains('AdminActionCenterScreen(churchId: churchId)'));
    expect(source, contains("title: 'Operations Reports'"));
    expect(
      source,
      contains('AdminOperationsReportsScreen(churchId: churchId)'),
    );
    expect(source, contains("title: 'Administrative Activity'"));
    expect(source, contains('AdminActivityLogScreen(churchId: churchId)'));
    expect(source, contains("title: 'Staff Access'"));
    expect(source, contains('AdminStaffAccessScreen(churchId: churchId)'));
  });

  test('phone staff access uses the same audited service as web', () {
    final source = File(
      'lib/screens/admin/admin_platform_tools_screen.dart',
    ).readAsStringSync();

    expect(source, contains('WebAdminStaffAccessScreen('));
    expect(source, contains('WebAdminAuditLogScreen('));
    expect(source, contains('WebAdminActionCenter('));
    expect(source, contains('WebAdminOperationsReports('));
    expect(source, contains('role != AppRoles.admin'));
  });
}
