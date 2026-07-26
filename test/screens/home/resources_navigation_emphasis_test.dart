import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Resources phone navigation is larger without glow', () {
    final shell = File(
      'lib/screens/home/churchsnap_shell.dart',
    ).readAsStringSync();

    expect(shell, contains("destination.label == 'Resources'"));
    expect(shell, contains('iconContainerWidth = prominent ? 54.0 : 46.0'));
    expect(shell, contains('iconContainerHeight = prominent ? 56.0 : 48.0'));
    expect(shell, contains('(prominent ? 51.0 : 45.0)'));
    expect(shell, contains('(prominent ? 48.0 : 41.0)'));
    expect(shell, contains('color: Colors.white.withValues('));
    expect(shell, contains('alpha: selected ? 1.0 : 0.88'));
    expect(shell, contains('width: selected ? 2.0 : 1.6'));
    expect(shell, contains('boxShadow: const <BoxShadow>[]'));
    expect(shell, contains('fontSize: prominent ? 9.75 : 8.5'));
    expect(shell, isNot(contains('blurRadius: prominent ? 19 : 15')));
    expect(shell, isNot(contains('blurRadius: 11')));
  });
}
