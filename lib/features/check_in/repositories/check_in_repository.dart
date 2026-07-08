import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/check_in_record.dart';

class CheckInRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> checkIn(CheckInRecord record) {
    return _firestore
        .collection('churches')
        .doc('demo-church')
        .collection('eventCheckIns')
        .add(record.toMap());
  }

  Stream<List<CheckInRecord>> watchCheckIns(String eventId) {
    return _firestore
        .collection('churches')
        .doc('demo-church')
        .collection('eventCheckIns')
        .where('eventId', isEqualTo: eventId)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => CheckInRecord.fromMap(doc.id, doc.data()))
              .toList(),
        );
  }

  Stream<List<CheckInRecord>> watchAllRecentCheckIns() {
    return _firestore
        .collection('churches')
        .doc('demo-church')
        .collection('eventCheckIns')
        .orderBy('checkedInAt', descending: true)
        .limit(50)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => CheckInRecord.fromMap(doc.id, doc.data()))
              .toList(),
        );
  }
}
