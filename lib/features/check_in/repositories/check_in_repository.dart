import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/check_in_record.dart';

class CheckInRepository {
  CheckInRepository({
    FirebaseFirestore? firestore,
    this.churchId = 'demo-church',
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;
  final String churchId;

  CollectionReference<Map<String, dynamic>> get _checkIns => _firestore
      .collection('churches')
      .doc(churchId)
      .collection('eventCheckIns');

  Future<void> checkIn(CheckInRecord record) {
    final data = record.toMap();
    data['churchId'] = churchId;

    return _checkIns.add(data);
  }

  Stream<List<CheckInRecord>> watchCheckIns(String eventId) {
    return _checkIns
        .where('eventId', isEqualTo: eventId)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (document) =>
                    CheckInRecord.fromMap(document.id, document.data()),
              )
              .toList(),
        );
  }

  Stream<List<CheckInRecord>> watchAllRecentCheckIns() {
    return _checkIns
        .orderBy('checkedInAt', descending: true)
        .limit(50)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (document) =>
                    CheckInRecord.fromMap(document.id, document.data()),
              )
              .toList(),
        );
  }
}
