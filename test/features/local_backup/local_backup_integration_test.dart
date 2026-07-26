import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('admin dashboard exposes Data Management', () {
    final dashboard = File(
      'lib/screens/admin/admin_dashboard_screen.dart',
    ).readAsStringSync();

    expect(dashboard, contains("import 'admin_data_management_screen.dart';"));
    expect(dashboard, contains("title: 'Data Management'"));
    expect(
      dashboard,
      contains('AdminDataManagementScreen(churchId: churchId)'),
    );
  });

  test('backup service enforces role admin and records an audit entry', () {
    final service = File(
      'lib/features/local_backup/services/'
      'churchsnap_local_backup_service.dart',
    ).readAsStringSync();

    expect(service, contains('role != AppRoles.admin'));
    expect(service, contains("data['isActive']"));
    expect(service, contains('FilePicker.platform.saveFile'));
    expect(service, contains("'local_backup_created'"));
    expect(service, contains("'admin_audit_logs'"));
    expect(service, contains("'group_ministry_join_requests'"));
    expect(service, isNot(contains("collection('giving')")));
  });

  test('phase 1 exclusions are documented in the implementation', () {
    final service = File(
      'lib/features/local_backup/services/'
      'churchsnap_local_backup_service.dart',
    ).readAsStringSync();

    expect(service, contains('Firebase Storage binary files'));
    expect(service, contains('Member-only sermon bookmark subcollections'));
    expect(service, contains('Restore operations and offline synchronisation'));
  });
}
