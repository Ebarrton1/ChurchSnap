import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../models/announcement.dart';

class AnnouncementRepository {
  AnnouncementRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  static const String defaultChurchId = 'demo-church';

  Stream<List<Announcement>> watchPublishedAnnouncements({
    String churchId = defaultChurchId,
  }) {
    return _firestore
        .collection('churches')
        .doc(churchId)
        .collection('announcements')
        .where('published', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
          final announcements = snapshot.docs
              .map((doc) => Announcement.fromMap(doc.id, doc.data()))
              .toList();

          announcements.sort((a, b) {
            final aDate = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
            final bDate = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
            return bDate.compareTo(aDate);
          });

          return announcements;
        });
  }
}
