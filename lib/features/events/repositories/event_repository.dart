import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../firebase/firebase_paths.dart';
import '../../../models/church_event.dart';

class EventRepository {
  EventRepository({FirebaseFirestore? firestore, this.churchId = 'demo-church'})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;
  final String churchId;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection(FirebasePaths.events(churchId));

  Stream<List<ChurchEvent>> watchPublishedEvents() {
    return _collection.snapshots().map((snapshot) {
      final events = snapshot.docs
          .where((document) {
            return document.data()['published'] != false;
          })
          .map((document) {
            return ChurchEvent.fromMap(document.id, document.data());
          })
          .toList();

      events.sort((first, second) {
        final firstDate =
            first.startDate ?? DateTime.fromMillisecondsSinceEpoch(0);
        final secondDate =
            second.startDate ?? DateTime.fromMillisecondsSinceEpoch(0);

        return firstDate.compareTo(secondDate);
      });

      return events;
    });
  }

  Future<void> addEvent(ChurchEvent event) {
    return _collection.add(event.toMap());
  }

  Future<void> updateEvent(String id, ChurchEvent event) {
    return _collection.doc(id).update(event.toMap());
  }

  Future<void> deleteEvent(String id) {
    return _collection.doc(id).delete();
  }

  Future<void> rsvpToEvent({required String eventId, required String userId}) {
    final eventReference = _collection.doc(eventId);

    return _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(eventReference);
      final data = snapshot.data() ?? {};

      final attendeeIds = List<String>.from(data['attendeeIds'] ?? const []);

      if (!attendeeIds.contains(userId)) {
        attendeeIds.add(userId);
      }

      transaction.update(eventReference, {
        'attendeeIds': attendeeIds,
        'rsvpCount': attendeeIds.length,
      });
    });
  }

  Future<void> cancelRsvp({required String eventId, required String userId}) {
    final eventReference = _collection.doc(eventId);

    return _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(eventReference);
      final data = snapshot.data() ?? {};

      final attendeeIds = List<String>.from(data['attendeeIds'] ?? const []);

      attendeeIds.remove(userId);

      transaction.update(eventReference, {
        'attendeeIds': attendeeIds,
        'rsvpCount': attendeeIds.length,
      });
    });
  }
}
