import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/volunteer_assignment.dart';

class VolunteerRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _assignments => _firestore
      .collection('churches')
      .doc('demo-church')
      .collection('volunteer_assignments');

  Stream<List<VolunteerAssignment>> watchAssignments() {
    return _assignments
        .orderBy('servingDate')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => VolunteerAssignment.fromMap(doc.id, doc.data()))
              .toList(),
        );
  }

  Stream<List<VolunteerAssignment>> watchAssignmentsForMember(String memberId) {
    return _assignments
        .where('memberId', isEqualTo: memberId)
        .orderBy('servingDate')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => VolunteerAssignment.fromMap(doc.id, doc.data()))
              .toList(),
        );
  }

  Future<void> addAssignment(VolunteerAssignment assignment) {
    return _assignments.add(assignment.toMap());
  }

  Future<void> updateAssignment(VolunteerAssignment assignment) {
    return _assignments.doc(assignment.id).update(assignment.toMap());
  }

  Future<void> deleteAssignment(String id) {
    return _assignments.doc(id).delete();
  }
}
