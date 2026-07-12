import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/repositories/firestore_collection_repository.dart';
import '../../../firebase/firebase_paths.dart';
import '../../../models/announcement.dart';

class AnnouncementRepository {
  AnnouncementRepository({
    FirebaseFirestore? firestore,
    this.churchId = 'demo-church',
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _repository = FirestoreCollectionRepository<Announcement>(
         firestore: firestore,
         collectionPath: FirebasePaths.announcements(churchId),
         fromMap: Announcement.fromMap,
       );

  final FirebaseFirestore _firestore;
  final String churchId;
  final FirestoreCollectionRepository<Announcement> _repository;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection(FirebasePaths.announcements(churchId));

  Stream<List<Announcement>> watchPublishedAnnouncements() {
    return _repository.watchPublished(dateField: 'createdAt', descending: true);
  }

  Future<void> addAnnouncement(Announcement announcement) {
    return _collection.add(announcement.toMap());
  }

  Future<void> updateAnnouncement(String id, Announcement announcement) {
    return _collection.doc(id).update(announcement.toMap());
  }

  Future<void> deleteAnnouncement(String id) {
    return _collection.doc(id).delete();
  }
}
