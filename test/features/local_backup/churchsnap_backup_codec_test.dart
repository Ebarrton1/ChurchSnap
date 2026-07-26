import 'dart:convert';

import 'package:churchsnap/features/local_backup/services/churchsnap_backup_codec.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ChurchSnapBackupCodec', () {
    test('encrypts and decrypts a ChurchSnap payload', () async {
      final codec = ChurchSnapBackupCodec(iterations: 1000);
      final payload = <String, Object?>{
        'churchId': 'alpha',
        'memberName': 'Backup Test Member',
        'count': 7,
      };

      final encrypted = await codec.encryptJson(
        payload: payload,
        password: 'correct-horse-battery-staple',
      );

      expect(utf8.decode(encrypted), isNot(contains('Backup Test Member')));

      final decrypted = await codec.decryptJson(
        encryptedBytes: encrypted,
        password: 'correct-horse-battery-staple',
      );

      expect(decrypted['churchId'], 'alpha');
      expect(decrypted['memberName'], 'Backup Test Member');
      expect(decrypted['count'], 7);
    });

    test('rejects an incorrect backup password', () async {
      final codec = ChurchSnapBackupCodec(iterations: 1000);
      final encrypted = await codec.encryptJson(
        payload: const <String, Object?>{'churchId': 'alpha'},
        password: 'correct-horse-battery-staple',
      );

      await expectLater(
        codec.decryptJson(
          encryptedBytes: encrypted,
          password: 'incorrect-password-value',
        ),
        throwsA(isA<ChurchSnapBackupCodecException>()),
      );
    });

    test('sanitizes credentials and Firestore value types', () {
      final value =
          ChurchSnapBackupSanitizer.encodeValue(<String, Object?>{
                'displayName': 'Member One',
                'fcmToken': 'should-not-be-exported',
                'passwordHash': 'should-not-be-exported',
                'createdAt': Timestamp.fromDate(DateTime.utc(2026, 7, 26, 16)),
                'location': GeoPoint(18.0179, -76.8099),
              })
              as Map<String, Object?>;

      expect(value['displayName'], 'Member One');
      expect(value['fcmToken'], isA<Map<String, Object?>>());
      expect(value['passwordHash'], isA<Map<String, Object?>>());

      final createdAt = value['createdAt'] as Map<String, Object?>;
      final location = value['location'] as Map<String, Object?>;

      expect(createdAt['__type'], 'timestamp');
      expect(location['__type'], 'geopoint');
      expect(location['latitude'], 18.0179);
    });
  });
}
