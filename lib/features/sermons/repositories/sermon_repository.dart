import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/repositories/firestore_collection_repository.dart';
import '../../../models/sermon.dart';

class SermonRepository {
  SermonRepository({FirebaseFirestore? firestore})
    : _repository = FirestoreCollectionRepository<Sermon>(
        firestore: firestore,
        collectionPath: 'churches/demo-church/sermons',
        fromMap: Sermon.fromMap,
      );

  final FirestoreCollectionRepository<Sermon> _repository;

  Stream<List<Sermon>> watchPublishedSermons() {
    return _repository.watchPublished(
      dateField: 'sermonDate',
      descending: true,
    );
  }
}
