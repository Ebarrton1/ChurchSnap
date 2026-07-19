import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('web Giving exposes pending gift confirmations and descriptions', () {
    final source = File(
      'lib/features/web_admin/screens/churchsnap_web_admin_shell.dart',
    ).readAsStringSync();

    expect(
      source,
      contains(
        "import '../../../screens/admin/admin_giving_confirmations_screen.dart';",
      ),
    );
    expect(
      source,
      contains('banner: _WebPendingGivingBanner(churchId: churchId)'),
    );
    expect(
      source,
      contains('class _WebPendingGivingBanner extends StatelessWidget'),
    );
    expect(source, contains(".collection('giving_submissions')"));
    expect(source, contains(".where('status', isEqualTo: 'pending')"));
    expect(
      source,
      matches(
        RegExp(
          r"const\s*\[\s*'description'\s*,\s*'donationDescription'\s*,"
          r"\s*'memo'\s*,?\s*\]",
        ),
      ),
    );
    expect(source, contains('Description preview:'));
    expect(source, contains('AdminGivingConfirmationsScreen('));
    expect(source, contains("label: const Text('Review pending gifts')"));
  });

  test('web record pages support an optional header banner', () {
    final source = File(
      'lib/features/web_admin/screens/churchsnap_web_admin_shell.dart',
    ).readAsStringSync();

    expect(source, contains('final Widget? banner;'));
    expect(source, contains('headerContent: banner'));
    expect(source, contains('final Widget? headerContent;'));
    expect(source, contains('if (headerContent != null)'));
  });
}
