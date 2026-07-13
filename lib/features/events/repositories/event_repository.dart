import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../firebase/firebase_paths.dart';
import '../../../models/church_event.dart';

class EventRepository {
  EventRepository({
    FirebaseFirestore? firestore,
    String churchId = 'demo-church',
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       churchId = churchId.trim().isEmpty ? 'demo-church' : churchId.trim();

  final FirebaseFirestore _firestore;
  final String churchId;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection(FirebasePaths.events(churchId));

  Stream<List<ChurchEvent>> watchPublishedEvents() {
    return _collection.where('published', isEqualTo: true).snapshots().map((
      snapshot,
    ) {
      final events = snapshot.docs
          .map((document) => ChurchEvent.fromMap(document.id, document.data()))
          .toList();

      events.sort((first, second) {
        final firstDate = first.startDate;
        final secondDate = second.startDate;

        if (firstDate == null && secondDate == null) {
          return first.title.compareTo(second.title);
        }

        if (firstDate == null) {
          return 1;
        }

        if (secondDate == null) {
          return -1;
        }

        return firstDate.compareTo(secondDate);
      });

      return events;
    });
  }

  Stream<List<ChurchEvent>> watchAllEvents() {
    return _watchEvents(includeUnpublished: true);
  }

  Stream<List<ChurchEvent>> _watchEvents({required bool includeUnpublished}) {
    return _collection.snapshots().map((snapshot) {
      final events = snapshot.docs
          .where((document) {
            if (includeUnpublished) {
              return true;
            }

            return document.data()['published'] == true;
          })
          .map((document) => ChurchEvent.fromMap(document.id, document.data()))
          .toList();

      events.sort((first, second) {
        final firstDate = first.startDate;
        final secondDate = second.startDate;

        if (firstDate == null && secondDate == null) {
          return first.title.compareTo(second.title);
        }

        if (firstDate == null) {
          return 1;
        }

        if (secondDate == null) {
          return -1;
        }

        return firstDate.compareTo(secondDate);
      });

      return events;
    });
  }

  Future<void> addEvent(ChurchEvent event) {
    return _collection.add(event.toMap());
  }

  Future<void> updateEvent(String id, ChurchEvent event) {
    return _collection.doc(_requireDocumentId(id, 'id')).update(event.toMap());
  }

  Future<void> deleteEvent(String id) {
    return _collection.doc(_requireDocumentId(id, 'id')).delete();
  }

  Future<void> rsvpToEvent({required String eventId, required String userId}) {
    final cleanEventId = _requireDocumentId(eventId, 'eventId');

    final cleanUserId = _requireDocumentId(userId, 'userId');

    final eventReference = _collection.doc(cleanEventId);

    return _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(eventReference);

      if (!snapshot.exists) {
        throw StateError('The selected event no longer exists.');
      }

      final data = snapshot.data() ?? {};

      final attendeeIds = List<String>.from(data['attendeeIds'] ?? const []);

      if (!attendeeIds.contains(cleanUserId)) {
        attendeeIds.add(cleanUserId);
      }

      transaction.update(eventReference, {
        'attendeeIds': attendeeIds,
        'rsvpCount': attendeeIds.length,
      });
    });
  }

  Future<void> cancelRsvp({required String eventId, required String userId}) {
    final cleanEventId = _requireDocumentId(eventId, 'eventId');

    final cleanUserId = _requireDocumentId(userId, 'userId');

    final eventReference = _collection.doc(cleanEventId);

    return _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(eventReference);

      if (!snapshot.exists) {
        throw StateError('The selected event no longer exists.');
      }

      final data = snapshot.data() ?? {};

      final attendeeIds = List<String>.from(data['attendeeIds'] ?? const []);

      attendeeIds.remove(cleanUserId);

      transaction.update(eventReference, {
        'attendeeIds': attendeeIds,
        'rsvpCount': attendeeIds.length,
      });
    });
  }

  String _requireDocumentId(String value, String argumentName) {
    final cleanValue = value.trim();

    if (cleanValue.isEmpty) {
      throw ArgumentError.value(
        value,
        argumentName,
        '$argumentName cannot be empty.',
      );
    }

    return cleanValue;
  }
}
