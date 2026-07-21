import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('opened member profile uses the web HTML image fallback', () {
    final source = File(
      'lib/screens/admin/admin_member_profile_screen.dart',
    ).readAsStringSync();
    final identityCardStart = source.indexOf(
      'class _MemberIdentityCard extends StatelessWidget',
    );

    expect(identityCardStart, isNonNegative);

    final imageStart = source.indexOf('Image.network(', identityCardStart);

    expect(imageStart, isNonNegative);

    final imageSnippet = source.substring(
      imageStart,
      (imageStart + 600).clamp(0, source.length),
    );

    expect(imageSnippet, contains('photoUrl,'));
    expect(
      imageSnippet,
      contains('webHtmlElementStrategy: WebHtmlElementStrategy.fallback'),
    );
  });
}
