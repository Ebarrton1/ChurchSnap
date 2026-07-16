import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:churchsnap/features/home/providers/pastor_appearance_provider.dart';

void main() {
  group('PastorAppearanceSettings', () {
    test('uses the bundled image when no URL is stored', () {
      const settings = PastorAppearanceSettings();

      expect(settings.usesDefaultImage, isTrue);
      expect(settings.imageUrl, isEmpty);
      expect(settings.storagePath, isEmpty);
    });

    test('parses stored pastor appearance fields', () {
      final timestamp = Timestamp.fromDate(DateTime.utc(2026, 7, 16, 1, 0));

      final settings = PastorAppearanceSettings.fromMap({
        'imageUrl': ' https://example.com/pastor.jpg ',
        'storagePath': ' churches/demo/home/pastor.jpg ',
        'updatedAt': timestamp,
      });

      expect(settings.usesDefaultImage, isFalse);
      expect(settings.imageUrl, 'https://example.com/pastor.jpg');
      expect(settings.storagePath, 'churches/demo/home/pastor.jpg');
      expect(settings.updatedAt, timestamp.toDate());
    });

    test('handles a missing Firestore document', () {
      final settings = PastorAppearanceSettings.fromMap(null);

      expect(settings.usesDefaultImage, isTrue);
      expect(settings.updatedAt, isNull);
    });
  });
}
