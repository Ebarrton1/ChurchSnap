import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';

class MediaStorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> uploadMediaFile({
    required File file,
    required String churchId,
    required String mediaType,
    required String fileName,
  }) async {
    final path =
        'churches/$churchId/media/$mediaType/${DateTime.now().millisecondsSinceEpoch}_$fileName';

    final ref = _storage.ref(path);

    await ref.putFile(file);

    return ref.getDownloadURL();
  }

  Future<void> deleteMediaFile(String url) async {
    if (url.trim().isEmpty) return;

    final ref = _storage.refFromURL(url);
    await ref.delete();
  }
}
