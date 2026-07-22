import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../firebase/firebase_paths.dart';
import '../../../models/prayer_request.dart';

class PrayerRepository {
  PrayerRepository({
    FirebaseFirestore? firestore,
    String churchId = 'demo-church',
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       churchId = churchId.trim().isEmpty ? 'demo-church' : churchId.trim();

  final FirebaseFirestore _firestore;
  final String churchId;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection(FirebasePaths.prayerRequests(churchId));

  Stream<List<PrayerRequest>> watchPublishedPrayerRequests() {
    return _collection
        .where('published', isEqualTo: true)
        .where('isPrivate', isEqualTo: false)
        .snapshots()
        .map((snapshot) {
          final requests = snapshot.docs
              .map(
                (document) =>
                    PrayerRequest.fromMap(document.id, document.data()),
              )
              .where((request) => request.published && !request.isPrivate)
              .toList();

          _sortNewestFirst(requests);
          return requests;
        });
  }

  Stream<List<PrayerRequest>> watchAllPrayerRequests() {
    return _collection.snapshots().map((snapshot) {
      final requests = snapshot.docs
          .map(
            (document) => PrayerRequest.fromMap(document.id, document.data()),
          )
          .toList();

      _sortNewestFirst(requests);
      return requests;
    });
  }

  Future<void> addPrayerRequest(PrayerRequest request) {
    return _collection.add(request.toMap());
  }

  Future<void> setPublished({
    required String prayerId,
    required bool published,
  }) {
    final cleanPrayerId = prayerId.trim();

    if (cleanPrayerId.isEmpty) {
      throw ArgumentError.value(
        prayerId,
        'prayerId',
        'Prayer request ID cannot be empty.',
      );
    }

    return _collection.doc(cleanPrayerId).update({'published': published});
  }

  Future<void> deletePrayerRequest(String prayerId) {
    final cleanPrayerId = prayerId.trim();

    if (cleanPrayerId.isEmpty) {
      throw ArgumentError.value(
        prayerId,
        'prayerId',
        'Prayer request ID cannot be empty.',
      );
    }

    return _collection.doc(cleanPrayerId).delete();
  }

  void _sortNewestFirst(List<PrayerRequest> requests) {
    requests.sort((first, second) {
      final firstDate = first.createdAt;
      final secondDate = second.createdAt;

      if (firstDate == null && secondDate == null) {
        return 0;
      }

      if (firstDate == null) {
        return 1;
      }

      if (secondDate == null) {
        return -1;
      }

      return secondDate.compareTo(firstDate);
    });
  }
}
