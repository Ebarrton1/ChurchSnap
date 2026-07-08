import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/media_item.dart';

class MediaRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _media =>
      _firestore.collection('churches').doc('demo-church').collection('media');

  Stream<List<MediaItem>> watchMedia() {
    return _media
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => MediaItem.fromMap(doc.id, doc.data()))
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
