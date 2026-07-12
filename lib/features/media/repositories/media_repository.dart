import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/media_item.dart';

class MediaRepository {
  MediaRepository({FirebaseFirestore? firestore, this.churchId = 'demo-church'})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;
  final String churchId;

  CollectionReference<Map<String, dynamic>> get _media =>
      _firestore.collection('churches').doc(churchId).collection('media');

  Stream<List<MediaItem>> watchMedia() {
    return _media
        .where('published', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (document) => MediaItem.fromMap(document.id, document.data()),
              )
              .toList(),
        );
  }

  Future<void> addMedia(MediaItem item) {
    return _media.add(item.toMap());
  }

  Future<void> updateMedia(MediaItem item) {
    return _media.doc(item.id).update(item.toMap());
  }

  Future<void> deleteMedia(String id) {
    return _media.doc(id).delete();
  }
}
