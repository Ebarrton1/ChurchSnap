import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../models/church_resource.dart';

class ChurchResourceRepository {
  ChurchResourceRepository({
    required String churchId,
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
    FirebaseAuth? auth,
  }) : churchId = churchId.trim().isEmpty ? 'demo-church' : churchId.trim(),
       _firestore = firestore ?? FirebaseFirestore.instance,
       _storage = storage ?? FirebaseStorage.instance,
       _auth = auth ?? FirebaseAuth.instance;

  static const int maxUploadBytes = 25 * 1024 * 1024;

  final String churchId;
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;
  final FirebaseAuth _auth;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('churches').doc(churchId).collection('resources');

  Stream<List<ChurchResource>> watchPublishedResources() {
    return _collection
        .where('published', isEqualTo: true)
        .snapshots()
        .map(_mapAndSort);
  }

  Stream<List<ChurchResource>> watchAllResources() {
    return _collection.snapshots().map(_mapAndSort);
  }

  List<ChurchResource> _mapAndSort(
    QuerySnapshot<Map<String, dynamic>> snapshot,
  ) {
    final resources = snapshot.docs.map((document) {
      return ChurchResource.fromMap(document.id, document.data());
    }).toList();

    resources.sort((first, second) {
      final firstDate =
          first.updatedAt ??
          first.createdAt ??
          DateTime.fromMillisecondsSinceEpoch(0);
      final secondDate =
          second.updatedAt ??
          second.createdAt ??
          DateTime.fromMillisecondsSinceEpoch(0);

      final dateComparison = secondDate.compareTo(firstDate);

      if (dateComparison != 0) {
        return dateComparison;
      }

      return first.title.toLowerCase().compareTo(second.title.toLowerCase());
    });

    return resources;
  }

  Future<String> uploadResource({
    required String title,
    required String description,
    required ChurchResourceCategory category,
    required Uint8List bytes,
    required String fileName,
    required String contentType,
    required bool published,
  }) async {
    final cleanTitle = title.trim();

    if (cleanTitle.isEmpty) {
      throw const ChurchResourceRepositoryException(
        'Enter a resource title before uploading.',
      );
    }

    if (bytes.isEmpty) {
      throw const ChurchResourceRepositoryException(
        'The selected resource file is empty.',
      );
    }

    if (bytes.length > maxUploadBytes) {
      throw const ChurchResourceRepositoryException(
        'Resource files must be 25 MB or smaller.',
      );
    }

    final document = _collection.doc();
    final safeFileName = _safeFileName(fileName);
    final storagePath =
        'churches/$churchId/resources/${document.id}/$safeFileName';
    final storageReference = _storage.ref(storagePath);

    try {
      await storageReference.putData(
        bytes,
        SettableMetadata(
          contentType: contentType,
          customMetadata: {'originalFileName': fileName.trim()},
        ),
      );

      final downloadUrl = await storageReference.getDownloadURL();

      await document.set({
        'title': cleanTitle,
        'description': description.trim(),
        'category': category.storageValue,
        'kind': ChurchResourceKind.file.storageValue,
        'downloadUrl': downloadUrl,
        'externalUrl': '',
        'storagePath': storagePath,
        'fileName': fileName.trim(),
        'contentType': contentType,
        'sizeBytes': bytes.length,
        'published': published,
        'uploadedBy': _auth.currentUser?.uid ?? '',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return document.id;
    } catch (error) {
      try {
        await storageReference.delete();
      } catch (_) {
        // Best-effort cleanup when the metadata write fails.
      }

      rethrow;
    }
  }

  Future<String> addLinkResource({
    required String title,
    required String description,
    required ChurchResourceCategory category,
    required String externalUrl,
    required bool published,
  }) async {
    final cleanTitle = title.trim();
    final cleanUrl = externalUrl.trim();
    final uri = Uri.tryParse(cleanUrl);

    if (cleanTitle.isEmpty) {
      throw const ChurchResourceRepositoryException(
        'Enter a resource title before saving.',
      );
    }

    if (uri == null ||
        !uri.hasScheme ||
        (uri.scheme != 'https' && uri.scheme != 'http')) {
      throw const ChurchResourceRepositoryException(
        'Enter a complete http or https resource link.',
      );
    }

    final document = _collection.doc();

    await document.set({
      'title': cleanTitle,
      'description': description.trim(),
      'category': category.storageValue,
      'kind': ChurchResourceKind.link.storageValue,
      'downloadUrl': '',
      'externalUrl': cleanUrl,
      'storagePath': '',
      'fileName': '',
      'contentType': '',
      'sizeBytes': 0,
      'published': published,
      'uploadedBy': _auth.currentUser?.uid ?? '',
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    return document.id;
  }

  Future<void> setPublished({
    required String resourceId,
    required bool published,
  }) {
    return _collection.doc(_requireId(resourceId)).update({
      'published': published,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteResource(ChurchResource resource) async {
    final resourceId = _requireId(resource.id);
    final storagePath = resource.storagePath.trim();

    if (storagePath.isNotEmpty) {
      try {
        await _storage.ref(storagePath).delete();
      } on FirebaseException catch (error) {
        if (error.code != 'object-not-found') {
          rethrow;
        }
      }
    }

    await _collection.doc(resourceId).delete();
  }

  String _requireId(String value) {
    final cleanValue = value.trim();

    if (cleanValue.isEmpty) {
      throw const ChurchResourceRepositoryException(
        'The resource record is missing its document ID.',
      );
    }

    return cleanValue;
  }

  String _safeFileName(String value) {
    final cleanValue = value.trim().isEmpty ? 'resource' : value.trim();
    final sanitized = cleanValue.replaceAll(RegExp(r'[^A-Za-z0-9._-]'), '_');

    return sanitized.length > 120 ? sanitized.substring(0, 120) : sanitized;
  }
}

class ChurchResourceRepositoryException implements Exception {
  const ChurchResourceRepositoryException(this.message);

  final String message;

  @override
  String toString() => message;
}
