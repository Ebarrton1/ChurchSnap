import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/repositories/firestore_collection_repository.dart';
import '../../../models/church_event.dart';

class EventRepository {
  EventRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _repository = FirestoreCollectionRepository<ChurchEvent>(
        firestore: firestore,
        collectionPath: 'churches/demo-church/events',
        fromMap: ChurchEvent.fromMap,
      );

  final FirebaseFirestore _firestore;
  final FirestoreCollectionRepository<ChurchEvent> _repository;

  Stream<List<ChurchEvent>> watchPublishedEvents() {
    return _repository.watchPublished(
      dateField: 'startDate',
      descending: false,
    );
  }

  Future<void> addEvent(ChurchEvent event) {
    return _firestore
        .collection('churches')
        .doc('demo-church')
        .collection('events')
        .add(event.toMap());
  }

  Future<void> updateEvent(String id, ChurchEvent event) {
    return _firestore
        .collection('churches')
        .doc('demo-church')
        .collection('events')
        .doc(id)
        .update(event.toMap());
  }

  Future<void> deleteEvent(String id) {
    return _firestore
        .collection('churches')
        .doc('demo-church')
        .collection('events')
        .doc(id)
        .delete();
  }
}
