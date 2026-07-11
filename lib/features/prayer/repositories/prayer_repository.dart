import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/repositories/firestore_collection_repository.dart';
import '../../../firebase/firebase_paths.dart';
import '../../../models/prayer_request.dart';

class PrayerRepository {
  PrayerRepository({
    FirebaseFirestore? firestore,
    this.churchId = 'demo-church',
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _repository = FirestoreCollectionRepository<PrayerRequest>(
         firestore: firestore,
         collectionPath: FirebasePaths.prayerRequests(churchId),
         fromMap: PrayerRequest.fromMap,
       );

  final FirebaseFirestore _firestore;
  final FirestoreCollectionRepository<PrayerRequest> _repository;
  final String churchId;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection(FirebasePaths.prayerRequests(churchId));

  Stream<List<PrayerRequest>> watchPublishedPrayerRequests() {
    return _repository.watchPublished(dateField: 'createdAt', descending: true);
  }

  Future<void> addPrayerRequest(PrayerRequest request) {
    return _collection.add(request.toMap());
  }
}
