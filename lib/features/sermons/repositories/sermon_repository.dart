import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/repositories/firestore_collection_repository.dart';
import '../../../models/sermon.dart';

class SermonRepository {
  SermonRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _repository = FirestoreCollectionRepository<Sermon>(
        firestore: firestore,
        collectionPath: 'churches/demo-church/sermons',
        fromMap: Sermon.fromMap,
      );

  final FirebaseFirestore _firestore;
  final FirestoreCollectionRepository<Sermon> _repository;

  CollectionReference<Map<String, dynamic>> get _collection => _firestore
      .collection('churches')
      .doc('demo-church')
      .collection('sermons');

  Stream<List<Sermon>> watchPublishedSermons() {
    return _repository.watchPublished(
      dateField: 'sermonDate',
      descending: true,
    );
  }

  Stream<List<Sermon>> watchAllSermons() {
    return _collection
        .orderBy('sermonDate', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs.map((document) {
            return Sermon.fromMap(document.id, document.data());
          }).toList(),
        );
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
