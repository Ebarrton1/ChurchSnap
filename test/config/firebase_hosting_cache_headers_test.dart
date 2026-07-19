import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Flutter web app shell is configured for revalidation', () {
    final config =
        jsonDecode(File('firebase.json').readAsStringSync())
            as Map<String, dynamic>;
    final rawHosting = config['hosting'];
    final hostingTargets = rawHosting is List<dynamic>
        ? rawHosting
        : <dynamic>[rawHosting];

    const requiredSources = <String>{
      '/',
      '/index.html',
      '/flutter_bootstrap.js',
      '/flutter.js',
      '/flutter_service_worker.js',
      '/main.dart.js',
      '/manifest.json',
      '/version.json',
    };

    for (final rawTarget in hostingTargets) {
      expect(rawTarget, isA<Map<String, dynamic>>());

      final target = rawTarget as Map<String, dynamic>;
      final rules = (target['headers'] as List<dynamic>? ?? const <dynamic>[])
          .cast<Map<String, dynamic>>();
      final rulesBySource = <String, Map<String, dynamic>>{
        for (final rule in rules)
          if (rule['source'] is String) rule['source'] as String: rule,
      };

      for (final source in requiredSources) {
        expect(
          rulesBySource,
          contains(source),
          reason: 'Missing cache policy for $source',
        );

        final headers =
            (rulesBySource[source]!['headers'] as List<dynamic>? ??
                    const <dynamic>[])
                .cast<Map<String, dynamic>>();
        final valuesByKey = <String, String>{
          for (final header in headers)
            if (header['key'] is String && header['value'] is String)
              (header['key'] as String).toLowerCase():
                  header['value'] as String,
        };

        expect(
          valuesByKey['cache-control'],
          'no-cache, no-store, must-revalidate',
          reason: 'Incorrect Cache-Control for $source',
        );
        expect(valuesByKey['pragma'], 'no-cache');
        expect(valuesByKey['expires'], '0');
      }
    }
  });
}
