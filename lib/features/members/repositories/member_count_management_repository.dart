import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/member_count_summary.dart';

class MemberCountManagementRepository {
  MemberCountManagementRepository({
    FirebaseFirestore? firestore,
    required this.churchId,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;
  final String churchId;

  CollectionReference<Map<String, dynamic>> get _members =>
      _firestore.collection('churches').doc(churchId).collection('members');

  Stream<MemberCountSummary> watchSummary() {
    return _members.snapshots().map(MemberCountSummary.fromSnapshot);
  }

  Future<MemberCountSummary> recalculate() async {
    final snapshot = await _members.get();
    return MemberCountSummary.fromSnapshot(snapshot);
  }
}
