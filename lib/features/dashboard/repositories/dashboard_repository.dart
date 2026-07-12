import 'package:cloud_firestore/cloud_firestore.dart';

class DashboardRepository {
  DashboardRepository({
    FirebaseFirestore? firestore,
    this.churchId = 'demo-church',
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;
  final String churchId;

  DocumentReference<Map<String, dynamic>> get _church =>
      _firestore.collection('churches').doc(churchId);

  Stream<int> watchMemberCount() {
    return _church
        .collection('members')
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  Stream<int> watchEventCount() {
    return _church
        .collection('events')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs.where((document) {
            return document.data()['published'] != false;
          }).length,
        );
  }

  Stream<int> watchSmallGroupCount() {
    return _church
        .collection('small_groups')
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  Stream<int> watchMinistryCount() {
    return _church
        .collection('ministries')
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  Stream<int> watchMediaCount() {
    return _church
        .collection('media')
        .where('published', isEqualTo: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  Stream<int> watchCheckInCount() {
    return _church
        .collection('eventCheckIns')
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }
}
