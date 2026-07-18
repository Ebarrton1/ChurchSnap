import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../models/member_self_profile.dart';

class MemberSelfProfileRepository {
  MemberSelfProfileRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
    FirebaseStorage? storage,
    required this.churchId,
    required this.userId,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _auth = auth ?? FirebaseAuth.instance,
       _storage = storage ?? FirebaseStorage.instance;

  static const int maximumPhotoBytes = 5 * 1024 * 1024;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final FirebaseStorage _storage;
  final String churchId;
  final String userId;

  DocumentReference<Map<String, dynamic>> get _memberReference => _firestore
      .collection('churches')
      .doc(churchId)
      .collection('members')
      .doc(userId);

  DocumentReference<Map<String, dynamic>> get _privateReference => _firestore
      .collection('churches')
      .doc(churchId)
      .collection('memberPrivateProfiles')
      .doc(userId);

  Future<MemberSelfProfileSnapshot> load() async {
    _verifyAuthenticatedUser();

    final memberSnapshot = await _memberReference.get();

    if (!memberSnapshot.exists || memberSnapshot.data() == null) {
      throw StateError(
        'Your church member record could not be found. Contact a church administrator.',
      );
    }

    final privateSnapshot = await _privateReference.get();

    return MemberSelfProfileSnapshot.fromMaps(
      memberData: memberSnapshot.data()!,
      privateData: privateSnapshot.data() ?? <String, dynamic>{},
    );
  }

  Future<String> save({
    required MemberSelfProfileDraft draft,
    required String existingPhotoUrl,
    Uint8List? photoBytes,
    String? photoContentType,
  }) async {
    final authenticatedUser = _verifyAuthenticatedUser();
    final validationError = draft.validate();

    if (validationError != null) {
      throw ArgumentError(validationError);
    }

    final memberSnapshot = await _memberReference.get();

    if (!memberSnapshot.exists) {
      throw StateError(
        'Your church member record could not be found. Contact a church administrator.',
      );
    }

    var photoUrl = existingPhotoUrl.trim();

    if (photoBytes != null) {
      photoUrl = await _uploadPhoto(
        bytes: photoBytes,
        contentType: _safeContentType(photoContentType),
      );
    }

    final publicData = draft.publicDirectoryMap(photoUrl: photoUrl);
    final privateData = draft.privateProfileMap();

    final batch = _firestore.batch();

    batch.update(_memberReference, <String, dynamic>{
      ...publicData,
      'profileNameCompletedAt': FieldValue.serverTimestamp(),
      'selfProfileUpdatedAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    batch.set(_privateReference, <String, dynamic>{
      ...privateData,
      'marriageDate': _timestampOrNull(draft.marriageDate),
      'dateOfBirth': _timestampOrNull(draft.dateOfBirth),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    await batch.commit();

    try {
      await authenticatedUser.updateDisplayName(draft.displayName);
    } catch (_) {
      // The Firestore member record is the directory source of truth.
    }

    return photoUrl;
  }

  User _verifyAuthenticatedUser() {
    final authenticatedUser = _auth.currentUser;

    if (authenticatedUser == null || authenticatedUser.uid != userId) {
      throw StateError(
        'Your signed-in account could not be verified. Please sign in again.',
      );
    }

    return authenticatedUser;
  }

  Future<String> _uploadPhoto({
    required Uint8List bytes,
    required String contentType,
  }) async {
    if (bytes.isEmpty) {
      throw StateError('The selected profile picture is empty.');
    }

    if (bytes.length > maximumPhotoBytes) {
      throw StateError('The profile picture must be smaller than 5 MB.');
    }

    final extension = _extensionForContentType(contentType);
    final reference = _storage
        .ref()
        .child('churches')
        .child(churchId)
        .child('member_profile_photos')
        .child(userId)
        .child('profile.$extension');

    await reference.putData(
      bytes,
      SettableMetadata(
        contentType: contentType,
        cacheControl: 'public,max-age=3600',
        customMetadata: <String, String>{
          'churchId': churchId,
          'memberId': userId,
          'updatedBy': 'member',
        },
      ),
    );

    return reference.getDownloadURL();
  }

  static Timestamp? _timestampOrNull(DateTime? value) {
    if (value == null) {
      return null;
    }

    return Timestamp.fromDate(DateTime(value.year, value.month, value.day));
  }

  static String _safeContentType(String? contentType) {
    switch (contentType?.toLowerCase()) {
      case 'image/png':
        return 'image/png';
      case 'image/webp':
        return 'image/webp';
      case 'image/heic':
        return 'image/heic';
      case 'image/heif':
        return 'image/heif';
      case 'image/jpeg':
      case 'image/jpg':
      default:
        return 'image/jpeg';
    }
  }

  static String _extensionForContentType(String contentType) {
    switch (contentType) {
      case 'image/png':
        return 'png';
      case 'image/webp':
        return 'webp';
      case 'image/heic':
        return 'heic';
      case 'image/heif':
        return 'heif';
      case 'image/jpeg':
      default:
        return 'jpg';
    }
  }
}
