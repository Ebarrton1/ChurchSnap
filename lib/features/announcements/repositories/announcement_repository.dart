import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/repositories/firestore_collection_repository.dart';
import '../../../models/announcement.dart';

class AnnouncementRepository {
  AnnouncementRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _repository = FirestoreCollectionRepository<Announcement>(
        firestore: firestore,
        collectionPath: 'churches/demo-church/announcements',
        fromMap: Announcement.fromMap,
      );

  final FirebaseFirestore _firestore;
  final FirestoreCollectionRepository<Announcement> _repository;

  Stream<List<Announcement>> watchPublishedAnnouncements() {
    return _repository.watchPublished(dateField: 'createdAt', descending: true);
  }

  Future<void> addAnnouncement(Announcement announcement) {
    return _firestore
        .collection('churches')
        .doc('demo-church')
        .collection('announcements')
        .add(announcement.toMap());
  }

  Future<void> updateAnnouncement(String id, Announcement announcement) {
    return _firestore
        .collection('churches')
        .doc('demo-church')
        .collection('announcements')
        .doc(id)
        .update(announcement.toMap());
  }

  Future<void> deleteAnnouncement(String id) {
    return _firestore
        .collection('churches')
        .doc('demo-church')
        .collection('announcements')
        .doc(id)
        .delete();
  }
}
