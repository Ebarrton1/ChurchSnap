import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../models/church_event.dart';

class EventRepository {
  EventRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  static const String defaultChurchId = 'demo-church';

  Stream<List<ChurchEvent>> watchPublishedEvents({
    String churchId = defaultChurchId,
  }) {
    return _firestore
        .collection('churches')
        .doc(churchId)
        .collection('events')
        .where('published', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
          final events = snapshot.docs
              .map((doc) => ChurchEvent.fromMap(doc.id, doc.data()))
              .toList();

          events.sort((a, b) {
            final aDate = a.startDate ?? DateTime.fromMillisecondsSinceEpoch(0);
            final bDate = b.startDate ?? DateTime.fromMillisecondsSinceEpoch(0);
            return aDate.compareTo(bDate);
          });

          return events;
        });
  }
}
