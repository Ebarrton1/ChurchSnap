import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/volunteer_assignment.dart';

class VolunteerRepository {
  VolunteerRepository({
    FirebaseFirestore? firestore,
    this.churchId = 'demo-church',
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;
  final String churchId;

  CollectionReference<Map<String, dynamic>> get _assignments => _firestore
      .collection('churches')
      .doc(churchId)
      .collection('volunteer_assignments');

  Stream<List<VolunteerAssignment>> watchAssignments() {
    return _assignments.snapshots().map((snapshot) {
      final assignments = snapshot.docs
          .map(
            (document) =>
                VolunteerAssignment.fromMap(document.id, document.data()),
          )
          .toList();

      _sortAssignments(assignments);
      return assignments;
    });
  }

  Stream<List<VolunteerAssignment>> watchAssignmentsForMember(String memberId) {
    return _assignments.where('memberId', isEqualTo: memberId).snapshots().map((
      snapshot,
    ) {
      final assignments = snapshot.docs
          .map(
            (document) =>
                VolunteerAssignment.fromMap(document.id, document.data()),
          )
          .toList();

      _sortAssignments(assignments);
      return assignments;
    });
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

  void _sortAssignments(List<VolunteerAssignment> assignments) {
    assignments.sort((first, second) {
      final firstDate = first.servingDate;
      final secondDate = second.servingDate;

      if (firstDate == null && secondDate == null) {
        return 0;
      }

      if (firstDate == null) {
        return 1;
      }

      if (secondDate == null) {
        return -1;
      }

      return firstDate.compareTo(secondDate);
    });
  }
}
