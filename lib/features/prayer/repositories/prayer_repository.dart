import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/repositories/firestore_collection_repository.dart';
import '../../../models/prayer_request.dart';

class PrayerRepository {
  PrayerRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _repository = FirestoreCollectionRepository<PrayerRequest>(
        firestore: firestore,
        collectionPath: 'churches/demo-church/prayer_requests',
        fromMap: PrayerRequest.fromMap,
      );

  final FirebaseFirestore _firestore;
  final FirestoreCollectionRepository<PrayerRequest> _repository;

  Stream<List<PrayerRequest>> watchPublishedPrayerRequests() {
    return _repository.watchPublished(dateField: 'createdAt', descending: true);
  }

  Future<void> addPrayerRequest(PrayerRequest request) {
    return _firestore
        .collection('churches')
        .doc('demo-church')
        .collection('prayer_requests')
        .add(request.toMap());
  }
}
