import 'dart:convert';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AccountSessionRecord {
  const AccountSessionRecord({
    required this.exists,
    required this.sessionId,
    required this.isFromCache,
  });

  final bool exists;
  final String? sessionId;
  final bool isFromCache;
}

abstract class AccountSessionService {
  String? get currentSessionId;

  Future<bool> restoreSession({
    required String userId,
    required String churchId,
  });

  Future<void> claimSession({required String userId, required String churchId});

  Stream<AccountSessionRecord> watchSession(String userId);

  Future<void> releaseSession({required String userId});
}

class FirebaseAccountSessionService implements AccountSessionService {
  FirebaseAccountSessionService({
    FirebaseFirestore? firestore,
    Future<SharedPreferences> Function()? preferencesLoader,
    Random? secureRandom,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _preferencesLoader = preferencesLoader ?? SharedPreferences.getInstance,
       _secureRandom = secureRandom ?? Random.secure();

  static const String _collectionName = 'accountSessions';
  static const String _preferencePrefix = 'churchsnap_account_session_';

  final FirebaseFirestore _firestore;
  final Future<SharedPreferences> Function() _preferencesLoader;
  final Random _secureRandom;

  String? _currentSessionId;
  String? _currentUserId;

  @override
  String? get currentSessionId => _currentSessionId;

  @override
  Future<bool> restoreSession({
    required String userId,
    required String churchId,
  }) async {
    final normalizedUserId = userId.trim();
    final normalizedChurchId = churchId.trim();

    if (normalizedUserId.isEmpty || normalizedChurchId.isEmpty) {
      return false;
    }

    final localSessionId = await _loadOrCreateSessionId(normalizedUserId);
    final reference = _firestore
        .collection(_collectionName)
        .doc(normalizedUserId);

    return _firestore.runTransaction<bool>((transaction) async {
      final snapshot = await transaction.get(reference);
      final activeSessionId = (snapshot.data()?['sessionId'] as String? ?? '')
          .trim();

      if (!snapshot.exists || activeSessionId.isEmpty) {
        transaction.set(
          reference,
          _sessionData(sessionId: localSessionId, churchId: normalizedChurchId),
        );

        return true;
      }

      if (activeSessionId != localSessionId) {
        return false;
      }

      transaction.set(
        reference,
        _sessionData(sessionId: localSessionId, churchId: normalizedChurchId),
        SetOptions(merge: true),
      );

      return true;
    });
  }

  @override
  Future<void> claimSession({
    required String userId,
    required String churchId,
  }) async {
    final normalizedUserId = userId.trim();
    final normalizedChurchId = churchId.trim();

    if (normalizedUserId.isEmpty || normalizedChurchId.isEmpty) {
      throw StateError('A user and church are required for a device session.');
    }

    final localSessionId = await _loadOrCreateSessionId(normalizedUserId);

    await _firestore
        .collection(_collectionName)
        .doc(normalizedUserId)
        .set(
          _sessionData(sessionId: localSessionId, churchId: normalizedChurchId),
        );
  }

  @override
  Stream<AccountSessionRecord> watchSession(String userId) {
    final normalizedUserId = userId.trim();

    if (normalizedUserId.isEmpty) {
      return Stream<AccountSessionRecord>.value(
        const AccountSessionRecord(
          exists: false,
          sessionId: null,
          isFromCache: false,
        ),
      );
    }

    return _firestore
        .collection(_collectionName)
        .doc(normalizedUserId)
        .snapshots(includeMetadataChanges: true)
        .map((snapshot) {
          final sessionId = (snapshot.data()?['sessionId'] as String? ?? '')
              .trim();

          return AccountSessionRecord(
            exists: snapshot.exists,
            sessionId: sessionId.isEmpty ? null : sessionId,
            isFromCache: snapshot.metadata.isFromCache,
          );
        });
  }

  @override
  Future<void> releaseSession({required String userId}) async {
    final normalizedUserId = userId.trim();
    final localSessionId = _currentSessionId;

    if (normalizedUserId.isEmpty ||
        localSessionId == null ||
        _currentUserId != normalizedUserId) {
      return;
    }

    final reference = _firestore
        .collection(_collectionName)
        .doc(normalizedUserId);

    await _firestore.runTransaction<void>((transaction) async {
      final snapshot = await transaction.get(reference);
      final activeSessionId = (snapshot.data()?['sessionId'] as String? ?? '')
          .trim();

      if (snapshot.exists && activeSessionId == localSessionId) {
        transaction.delete(reference);
      }
    });
  }

  Future<String> _loadOrCreateSessionId(String userId) async {
    if (_currentUserId == userId && _currentSessionId != null) {
      return _currentSessionId!;
    }

    final preferences = await _preferencesLoader();
    final preferenceKey = '$_preferencePrefix$userId';
    final existingSessionId = (preferences.getString(preferenceKey) ?? '')
        .trim();

    final sessionId = existingSessionId.length >= 32
        ? existingSessionId
        : _generateSessionId();

    if (sessionId != existingSessionId) {
      await preferences.setString(preferenceKey, sessionId);
    }

    _currentUserId = userId;
    _currentSessionId = sessionId;

    return sessionId;
  }

  Map<String, dynamic> _sessionData({
    required String sessionId,
    required String churchId,
  }) {
    return <String, dynamic>{
      'sessionId': sessionId,
      'churchId': churchId,
      'platform': _platformLabel,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  String _generateSessionId() {
    final bytes = List<int>.generate(
      32,
      (_) => _secureRandom.nextInt(256),
      growable: false,
    );

    return base64UrlEncode(bytes).replaceAll('=', '');
  }

  String get _platformLabel {
    if (kIsWeb) {
      return 'web';
    }

    return defaultTargetPlatform.name;
  }
}

class NoopAccountSessionService implements AccountSessionService {
  NoopAccountSessionService({
    this.restoreAllowed = true,
    this.currentSessionIdValue = 'test-session',
  });

  final bool restoreAllowed;
  final String? currentSessionIdValue;

  @override
  String? get currentSessionId => currentSessionIdValue;

  @override
  Future<void> claimSession({
    required String userId,
    required String churchId,
  }) async {}

  @override
  Future<void> releaseSession({required String userId}) async {}

  @override
  Future<bool> restoreSession({
    required String userId,
    required String churchId,
  }) async {
    return restoreAllowed;
  }

  @override
  Stream<AccountSessionRecord> watchSession(String userId) {
    return Stream<AccountSessionRecord>.value(
      AccountSessionRecord(
        exists: true,
        sessionId: currentSessionIdValue,
        isFromCache: false,
      ),
    );
  }
}
