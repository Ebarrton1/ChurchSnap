import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/repositories/firestore_collection_repository.dart';
import '../../../firebase/firebase_paths.dart';
import '../../../models/sermon.dart';

class SermonRepository {
  SermonRepository({
    FirebaseFirestore? firestore,
    this.churchId = 'demo-church',
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _repository = FirestoreCollectionRepository<Sermon>(
         firestore: firestore,
         collectionPath: FirebasePaths.sermons(churchId),
         fromMap: Sermon.fromMap,
       );

  final FirebaseFirestore _firestore;
  final FirestoreCollectionRepository<Sermon> _repository;
  final String churchId;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection(FirebasePaths.sermons(churchId));

  Stream<List<Sermon>> watchPublishedSermons() {
    return _repository.watchPublished(
      dateField: 'sermonDate',
      descending: true,
    );
  }

  Stream<List<Sermon>> watchAllSermons() {
    return _collection.snapshots().map((snapshot) {
      final sermons = snapshot.docs.map((document) {
        return Sermon.fromMap(document.id, document.data());
      }).toList();

      sermons.sort((first, second) {
        final firstDate =
            first.sermonDate ??
            first.createdAt ??
            DateTime.fromMillisecondsSinceEpoch(0);
        final secondDate =
            second.sermonDate ??
            second.createdAt ??
            DateTime.fromMillisecondsSinceEpoch(0);

        return secondDate.compareTo(firstDate);
      });

      return sermons;
    });
  }

  Future<String> addSermon(Sermon sermon) async {
    final document = await _collection.add(sermon.toMap());
    return document.id;
  }

  Future<void> updateSermon(String sermonId, Sermon sermon) async {
    if (sermonId.trim().isEmpty) {
      throw ArgumentError('A sermon ID is required.');
    }

    await _collection.doc(sermonId).update(sermon.toMap());
  }

  Future<void> deleteSermon(String sermonId) async {
    if (sermonId.trim().isEmpty) {
      throw ArgumentError('A sermon ID is required.');
    }

    await _collection.doc(sermonId).delete();
  }

  Future<void> setPublished({
    required String sermonId,
    required bool published,
  }) async {
    if (sermonId.trim().isEmpty) {
      throw ArgumentError('A sermon ID is required.');
    }

    await _collection.doc(sermonId).update({'published': published});
  }

  Future<void> setFeatured(String sermonId) async {
    if (sermonId.trim().isEmpty) {
      throw ArgumentError('A sermon ID is required.');
    }

    final featuredSermons = await _collection
        .where('featured', isEqualTo: true)
        .get();

    final batch = _firestore.batch();

    for (final document in featuredSermons.docs) {
      batch.update(document.reference, {'featured': false});
    }

    batch.update(_collection.doc(sermonId), {'featured': true});

    await batch.commit();
  }
}
