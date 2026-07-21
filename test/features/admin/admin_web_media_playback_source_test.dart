import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('admin media exposes browser playback controls', () {
    final source = File(
      'lib/screens/admin/admin_media_screen.dart',
    ).readAsStringSync();

    expect(source, contains('ExternalMediaLauncher.open'));
    expect(source, contains('item.mediaUrl.trim()'));
    expect(source, contains('Icons.open_in_new_rounded'));
  });

  test('admin sermons expose video or audio playback controls', () {
    final source = File(
      'lib/screens/admin/admin_sermons_screen.dart',
    ).readAsStringSync();

    expect(source, contains("value: 'play'"));
    expect(source, contains('sermon.videoUrl.trim()'));
    expect(source, contains('sermon.audioUrl.trim()'));
    expect(source, contains('ExternalMediaLauncher.open'));
  });

  test('external media launcher opens web URLs in a new tab', () {
    final source = File(
      'lib/core/services/external_media_launcher.dart',
    ).readAsStringSync();

    expect(source, contains("webOnlyWindowName: '_blank'"));
    expect(source, contains("uri.scheme != 'http'"));
    expect(source, contains("uri.scheme != 'https'"));
  });
}
