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

  Future<void> rsvpToEvent({required String eventId, required String userId}) {
    final eventRef = _firestore
        .collection('churches')
        .doc('demo-church')
        .collection('events')
        .doc(eventId);

    return _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(eventRef);
      final data = snapshot.data() ?? {};

      final attendeeIds = List<String>.from(data['attendeeIds'] ?? const []);

      if (!attendeeIds.contains(userId)) {
        attendeeIds.add(userId);
      }

      transaction.update(eventRef, {
        'attendeeIds': attendeeIds,
        'rsvpCount': attendeeIds.length,
      });
    });
  }

  Future<void> cancelRsvp({required String eventId, required String userId}) {
    final eventRef = _firestore
        .collection('churches')
        .doc('demo-church')
        .collection('events')
        .doc(eventId);

    return _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(eventRef);
      final data = snapshot.data() ?? {};

      final attendeeIds = List<String>.from(data['attendeeIds'] ?? const []);

      attendeeIds.remove(userId);

      transaction.update(eventRef, {
        'attendeeIds': attendeeIds,
        'rsvpCount': attendeeIds.length,
      });
    });
  }
}
