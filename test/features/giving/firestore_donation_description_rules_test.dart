import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('donation description Firestore rules use valid expressions', () {
    final rules = File('firestore.rules').readAsStringSync();

    expect(RegExp(r'&&\s*&&').hasMatch(rules), isFalse);
    expect(RegExp(r'&&\s*==').hasMatch(rules), isFalse);

    expect(
      RegExp(
        r"request\.resource\.data\.get\('description', ''\)"
        r"\s+is\s+string",
      ).hasMatch(rules),
      isTrue,
    );
    expect(
      RegExp(
        r"request\.resource\.data\.get\('description', ''\)"
        r"\.size\(\)\s*<=\s*500",
      ).hasMatch(rules),
      isTrue,
    );
    expect(
      RegExp(
        r"request\.resource\.data\.get\('description', ''\)"
        r"\s*==\s*"
        r"resource\.data\.get\('description', ''\)",
      ).hasMatch(rules),
      isTrue,
    );
  });
}
