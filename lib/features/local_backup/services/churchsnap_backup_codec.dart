import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cryptography/cryptography.dart';

class ChurchSnapBackupCodec {
  ChurchSnapBackupCodec({this.iterations = 210000, Random? random})
    : assert(iterations >= 1000),
      _random = random ?? Random.secure();

  static const String encryptedFormat = 'churchsnap.encrypted-local-backup';
  static const int encryptedFormatVersion = 1;
  static const String cipherName = 'AES-256-GCM';
  static const String kdfName = 'PBKDF2-HMAC-SHA256';

  final int iterations;
  final Random _random;

  final AesGcm _cipher = AesGcm.with256bits();

  List<int> get _additionalData =>
      utf8.encode('$encryptedFormat.v$encryptedFormatVersion');

  Future<Uint8List> encryptJson({
    required Map<String, Object?> payload,
    required String password,
  }) async {
    if (password.length < 12) {
      throw const ChurchSnapBackupCodecException(
        'The backup password must contain at least 12 characters.',
      );
    }

    final salt = _randomBytes(16);
    final nonce = _randomBytes(12);
    final secretKey = await _deriveKey(
      password: password,
      salt: salt,
      iterationCount: iterations,
    );

    final clearText = utf8.encode(
      const JsonEncoder.withIndent('  ').convert(payload),
    );

    final secretBox = await _cipher.encrypt(
      clearText,
      secretKey: secretKey,
      nonce: nonce,
      aad: _additionalData,
    );

    final envelope = <String, Object?>{
      'format': encryptedFormat,
      'formatVersion': encryptedFormatVersion,
      'cipher': cipherName,
      'kdf': kdfName,
      'iterations': iterations,
      'salt': base64Encode(salt),
      'nonce': base64Encode(secretBox.nonce),
      'cipherText': base64Encode(secretBox.cipherText),
      'mac': base64Encode(secretBox.mac.bytes),
    };

    return Uint8List.fromList(
      utf8.encode(const JsonEncoder.withIndent('  ').convert(envelope)),
    );
  }

  Future<Map<String, dynamic>> decryptJson({
    required List<int> encryptedBytes,
    required String password,
  }) async {
    try {
      final decoded = jsonDecode(utf8.decode(encryptedBytes));

      if (decoded is! Map<String, dynamic>) {
        throw const ChurchSnapBackupCodecException(
          'The selected file is not a valid ChurchSnap backup.',
        );
      }

      if (decoded['format'] != encryptedFormat ||
          decoded['formatVersion'] != encryptedFormatVersion ||
          decoded['cipher'] != cipherName ||
          decoded['kdf'] != kdfName) {
        throw const ChurchSnapBackupCodecException(
          'This ChurchSnap backup format is not supported.',
        );
      }

      final storedIterations = decoded['iterations'];

      if (storedIterations is! int || storedIterations < 1000) {
        throw const ChurchSnapBackupCodecException(
          'The ChurchSnap backup encryption settings are invalid.',
        );
      }

      final salt = base64Decode(_requiredText(decoded, 'salt'));
      final nonce = base64Decode(_requiredText(decoded, 'nonce'));
      final cipherText = base64Decode(_requiredText(decoded, 'cipherText'));
      final mac = base64Decode(_requiredText(decoded, 'mac'));

      final secretKey = await _deriveKey(
        password: password,
        salt: salt,
        iterationCount: storedIterations,
      );

      final clearText = await _cipher.decrypt(
        SecretBox(cipherText, nonce: nonce, mac: Mac(mac)),
        secretKey: secretKey,
        aad: _additionalData,
      );

      final payload = jsonDecode(utf8.decode(clearText));

      if (payload is! Map<String, dynamic>) {
        throw const ChurchSnapBackupCodecException(
          'The decrypted ChurchSnap backup payload is invalid.',
        );
      }

      return payload;
    } on ChurchSnapBackupCodecException {
      rethrow;
    } on SecretBoxAuthenticationError {
      throw const ChurchSnapBackupCodecException(
        'The backup password is incorrect or the file was altered.',
      );
    } on FormatException {
      throw const ChurchSnapBackupCodecException(
        'The selected file is not a valid ChurchSnap backup.',
      );
    }
  }

  Future<SecretKey> _deriveKey({
    required String password,
    required List<int> salt,
    required int iterationCount,
  }) {
    final algorithm = Pbkdf2(
      macAlgorithm: Hmac.sha256(),
      iterations: iterationCount,
      bits: 256,
    );

    return algorithm.deriveKey(
      secretKey: SecretKey(utf8.encode(password)),
      nonce: salt,
    );
  }

  Uint8List _randomBytes(int length) {
    return Uint8List.fromList(
      List<int>.generate(length, (_) => _random.nextInt(256)),
    );
  }

  static String _requiredText(Map<String, dynamic> data, String key) {
    final value = data[key];

    if (value is! String || value.trim().isEmpty) {
      throw ChurchSnapBackupCodecException(
        'The ChurchSnap backup is missing $key.',
      );
    }

    return value;
  }
}

class ChurchSnapBackupSanitizer {
  const ChurchSnapBackupSanitizer._();

  static Object? encodeValue(Object? value, {String? fieldName}) {
    if (fieldName != null && isSensitiveField(fieldName)) {
      return const <String, Object?>{
        '__type': 'redacted',
        'reason': 'Sensitive credential or payment field excluded.',
      };
    }

    if (value == null || value is String || value is num || value is bool) {
      return value;
    }

    if (value is Timestamp) {
      return <String, Object?>{
        '__type': 'timestamp',
        'value': value.toDate().toUtc().toIso8601String(),
      };
    }

    if (value is DateTime) {
      return <String, Object?>{
        '__type': 'datetime',
        'value': value.toUtc().toIso8601String(),
      };
    }

    if (value is GeoPoint) {
      return <String, Object?>{
        '__type': 'geopoint',
        'latitude': value.latitude,
        'longitude': value.longitude,
      };
    }

    if (value is DocumentReference) {
      return <String, Object?>{
        '__type': 'document_reference',
        'path': value.path,
      };
    }

    if (value is Blob) {
      return const <String, Object?>{
        '__type': 'firestore_blob',
        'excluded': true,
        'reason': 'Binary Firestore blobs are excluded from phase 1 backups.',
      };
    }

    if (value is Map) {
      final output = <String, Object?>{};

      for (final entry in value.entries) {
        final key = entry.key.toString();
        output[key] = encodeValue(entry.value, fieldName: key);
      }

      return output;
    }

    if (value is Iterable) {
      return value.map((item) => encodeValue(item)).toList(growable: false);
    }

    return <String, Object?>{
      '__type': 'unsupported_value',
      'runtimeType': value.runtimeType.toString(),
      'value': value.toString(),
    };
  }

  static bool isSensitiveField(String fieldName) {
    final normalized = fieldName.toLowerCase().replaceAll(
      RegExp(r'[^a-z0-9]'),
      '',
    );

    return normalized.contains('password') ||
        normalized.contains('secret') ||
        normalized.contains('privatekey') ||
        normalized == 'accesstoken' ||
        normalized == 'refreshtoken' ||
        normalized == 'idtoken' ||
        normalized == 'fcmtoken' ||
        normalized == 'fcmtokens' ||
        normalized == 'messagingtoken' ||
        normalized == 'devicetoken' ||
        normalized == 'cardnumber' ||
        normalized == 'cvv' ||
        normalized == 'cvc' ||
        normalized == 'bankaccount' ||
        normalized == 'bankaccountnumber' ||
        normalized == 'routingnumber';
  }
}

class ChurchSnapBackupCodecException implements Exception {
  const ChurchSnapBackupCodecException(this.message);

  final String message;

  @override
  String toString() => message;
}
