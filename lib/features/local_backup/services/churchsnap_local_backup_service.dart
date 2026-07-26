import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../../../core/auth/app_roles.dart';
import 'churchsnap_backup_codec.dart';

typedef ChurchSnapBackupProgress = void Function(String message);

class ChurchSnapLocalBackupService {
  ChurchSnapLocalBackupService({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
    ChurchSnapBackupCodec? codec,
    required this.churchId,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _auth = auth ?? FirebaseAuth.instance,
       _codec = codec ?? ChurchSnapBackupCodec();

  static const List<String> includedCollections = <String>[
    'members',
    'memberPrivateProfiles',
    'announcements',
    'events',
    'resources',
    'sermons',
    'prayer_requests',
    'media',
    'eventCheckIns',
    'attendance',
    'settings',
    'notifications',
    'ministries',
    'small_groups',
    'volunteer_assignments',
    'giving_submissions',
    'giving_funds',
    'donations',
    'group_ministry_join_requests',
    'admin_audit_logs',
  ];

  static const List<String> excludedData = <String>[
    'Firebase Authentication passwords and credentials',
    'Firebase Storage binary files',
    'Raw payment-card and bank credentials',
    'Member-only sermon bookmark subcollections',
    'Restore operations and offline synchronisation',
  ];

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final ChurchSnapBackupCodec _codec;
  final String churchId;

  DocumentReference<Map<String, dynamic>> get _church =>
      _firestore.collection('churches').doc(churchId);

  Future<ChurchSnapLocalBackupAccess> checkAccess() async {
    final user = _auth.currentUser;

    if (user == null) {
      return const ChurchSnapLocalBackupAccess.denied(
        'Sign in before creating a local backup.',
      );
    }

    final member = await _church.collection('members').doc(user.uid).get();

    if (!member.exists) {
      return const ChurchSnapLocalBackupAccess.denied(
        'Your account is not connected to this church.',
      );
    }

    final data = member.data() ?? const <String, dynamic>{};
    final role = data['role']?.toString() ?? '';
    final isActive = data['isActive'] as bool? ?? true;

    if (!isActive) {
      return const ChurchSnapLocalBackupAccess.denied(
        'This administrator account is inactive.',
      );
    }

    if (role != AppRoles.admin) {
      return const ChurchSnapLocalBackupAccess.denied(
        'Only a ChurchSnap administrator can create a local backup.',
      );
    }

    return ChurchSnapLocalBackupAccess.allowed(
      userId: user.uid,
      displayName: _firstText(data, const <String>[
        'displayName',
        'fullName',
        'name',
      ], fallback: user.displayName ?? 'ChurchSnap Administrator'),
      email: _firstText(data, const <String>[
        'email',
      ], fallback: user.email ?? ''),
    );
  }

  Future<ChurchSnapLocalBackupResult> createEncryptedBackup({
    required String password,
    ChurchSnapBackupProgress? onProgress,
  }) async {
    if (churchId.trim().isEmpty) {
      throw const ChurchSnapLocalBackupException(
        'The church identifier is missing.',
      );
    }

    if (password.length < 12) {
      throw const ChurchSnapLocalBackupException(
        'Use a backup password with at least 12 characters.',
      );
    }

    onProgress?.call('Verifying administrator access...');

    final access = await checkAccess();

    if (!access.isAllowed) {
      throw ChurchSnapLocalBackupException(access.reason);
    }

    onProgress?.call('Reading the church record...');

    final churchSnapshot = await _church.get();
    final churchData = churchSnapshot.data() ?? const <String, dynamic>{};

    final collections = <String, Object?>{};
    final recordCounts = <String, int>{};
    var totalRecordCount = churchSnapshot.exists ? 1 : 0;

    for (final collectionName in includedCollections) {
      onProgress?.call('Collecting $collectionName...');

      final records = await _readCollection(collectionName);
      collections[collectionName] = records;
      recordCounts[collectionName] = records.length;
      totalRecordCount += records.length;
    }

    final createdAt = DateTime.now().toUtc();
    final churchName = _firstText(churchData, const <String>[
      'name',
      'churchName',
      'displayName',
    ], fallback: churchId);

    final payload = <String, Object?>{
      'format': 'churchsnap.firestore-local-backup',
      'formatVersion': 1,
      'scope': 'firestore-records-only',
      'churchId': churchId,
      'churchName': churchName,
      'createdAt': createdAt.toIso8601String(),
      'createdBy': <String, Object?>{
        'uid': access.userId,
        'displayName': access.displayName,
        'email': access.email,
        'role': AppRoles.admin,
      },
      'church': <String, Object?>{
        'id': churchSnapshot.id,
        'path': churchSnapshot.reference.path,
        'exists': churchSnapshot.exists,
        'data': ChurchSnapBackupSanitizer.encodeValue(churchData),
      },
      'collections': collections,
      'recordCounts': recordCounts,
      'totalRecordCount': totalRecordCount,
      'exclusions': excludedData,
    };

    onProgress?.call('Encrypting the backup...');

    final encryptedBytes = await _codec.encryptJson(
      payload: payload,
      password: password,
    );

    final fileName = _backupFileName(
      churchName: churchName,
      createdAt: createdAt,
    );

    onProgress?.call('Choose where to save the encrypted file...');

    final selectedPath = await FilePicker.platform.saveFile(
      dialogTitle: 'Save encrypted ChurchSnap backup',
      fileName: fileName,
      type: FileType.custom,
      allowedExtensions: const <String>['churchsnapbackup'],
      bytes: encryptedBytes,
    );

    if (selectedPath == null && !kIsWeb) {
      return ChurchSnapLocalBackupResult.cancelled();
    }

    onProgress?.call('Recording the administrative activity...');

    var auditLogged = true;

    try {
      await _church.collection('admin_audit_logs').add({
        'action': 'local_backup_created',
        'actorId': access.userId,
        'actorRole': AppRoles.admin,
        'targetMemberId': '',
        'targetDisplayName': 'Encrypted local backup',
        'previousRole': '',
        'newRole': '',
        'createdAt': FieldValue.serverTimestamp(),
        'fileName': fileName,
        'backupFormatVersion': 1,
        'recordCount': totalRecordCount,
        'collectionCount': includedCollections.length,
        'scope': 'firestore-records-only',
      });
    } catch (_) {
      auditLogged = false;
    }

    onProgress?.call('Encrypted local backup completed.');

    return ChurchSnapLocalBackupResult.completed(
      fileName: fileName,
      savedPath: selectedPath,
      recordCount: totalRecordCount,
      collectionCount: includedCollections.length,
      encryptedByteCount: encryptedBytes.length,
      auditLogged: auditLogged,
    );
  }

  Future<List<Map<String, Object?>>> _readCollection(
    String collectionName,
  ) async {
    const pageSize = 500;
    final records = <Map<String, Object?>>[];
    QueryDocumentSnapshot<Map<String, dynamic>>? lastDocument;

    while (true) {
      Query<Map<String, dynamic>> query = _church
          .collection(collectionName)
          .orderBy(FieldPath.documentId)
          .limit(pageSize);

      if (lastDocument != null) {
        query = query.startAfterDocument(lastDocument);
      }

      final page = await query.get();

      for (final document in page.docs) {
        records.add(<String, Object?>{
          'id': document.id,
          'path': document.reference.path,
          'data': ChurchSnapBackupSanitizer.encodeValue(document.data()),
        });
      }

      if (page.docs.length < pageSize) {
        break;
      }

      lastDocument = page.docs.last;
    }

    return records;
  }

  static String _backupFileName({
    required String churchName,
    required DateTime createdAt,
  }) {
    final safeChurchName = churchName
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
        .replaceAll(RegExp(r'^_+|_+$'), '');

    final name = safeChurchName.isEmpty ? 'church' : safeChurchName;
    final timestamp =
        '${createdAt.year.toString().padLeft(4, '0')}'
        '${createdAt.month.toString().padLeft(2, '0')}'
        '${createdAt.day.toString().padLeft(2, '0')}_'
        '${createdAt.hour.toString().padLeft(2, '0')}'
        '${createdAt.minute.toString().padLeft(2, '0')}'
        '${createdAt.second.toString().padLeft(2, '0')}';

    return 'churchsnap_${name}_$timestamp.churchsnapbackup';
  }

  static String _firstText(
    Map<String, dynamic> data,
    List<String> keys, {
    required String fallback,
  }) {
    for (final key in keys) {
      final value = data[key]?.toString().trim() ?? '';

      if (value.isNotEmpty) {
        return value;
      }
    }

    return fallback.trim();
  }
}

class ChurchSnapLocalBackupAccess {
  const ChurchSnapLocalBackupAccess._({
    required this.isAllowed,
    required this.reason,
    required this.userId,
    required this.displayName,
    required this.email,
  });

  const ChurchSnapLocalBackupAccess.allowed({
    required String userId,
    required String displayName,
    required String email,
  }) : this._(
         isAllowed: true,
         reason: '',
         userId: userId,
         displayName: displayName,
         email: email,
       );

  const ChurchSnapLocalBackupAccess.denied(String reason)
    : this._(
        isAllowed: false,
        reason: reason,
        userId: '',
        displayName: '',
        email: '',
      );

  final bool isAllowed;
  final String reason;
  final String userId;
  final String displayName;
  final String email;
}

class ChurchSnapLocalBackupResult {
  const ChurchSnapLocalBackupResult._({
    required this.wasCancelled,
    required this.fileName,
    required this.savedPath,
    required this.recordCount,
    required this.collectionCount,
    required this.encryptedByteCount,
    required this.auditLogged,
  });

  factory ChurchSnapLocalBackupResult.cancelled() {
    return const ChurchSnapLocalBackupResult._(
      wasCancelled: true,
      fileName: '',
      savedPath: null,
      recordCount: 0,
      collectionCount: 0,
      encryptedByteCount: 0,
      auditLogged: false,
    );
  }

  factory ChurchSnapLocalBackupResult.completed({
    required String fileName,
    required String? savedPath,
    required int recordCount,
    required int collectionCount,
    required int encryptedByteCount,
    required bool auditLogged,
  }) {
    return ChurchSnapLocalBackupResult._(
      wasCancelled: false,
      fileName: fileName,
      savedPath: savedPath,
      recordCount: recordCount,
      collectionCount: collectionCount,
      encryptedByteCount: encryptedByteCount,
      auditLogged: auditLogged,
    );
  }

  final bool wasCancelled;
  final String fileName;
  final String? savedPath;
  final int recordCount;
  final int collectionCount;
  final int encryptedByteCount;
  final bool auditLogged;
}

class ChurchSnapLocalBackupException implements Exception {
  const ChurchSnapLocalBackupException(this.message);

  final String message;

  @override
  String toString() => message;
}
