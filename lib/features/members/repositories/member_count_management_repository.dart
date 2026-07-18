import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/member_count_summary.dart';

class MemberCountManagementRepository {
  MemberCountManagementRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
    required this.churchId,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _auth = auth ?? FirebaseAuth.instance;

  static const int _batchSize = 400;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final String churchId;

  CollectionReference<Map<String, dynamic>> get _members =>
      _firestore.collection('churches').doc(churchId).collection('members');

  Stream<MemberCountSummary> watchSummary() {
    return _members.snapshots().map(MemberCountSummary.fromSnapshot);
  }

  Future<MemberCountSummary> getSummary() async {
    final snapshot = await _members.get();

    return MemberCountSummary.fromSnapshot(snapshot);
  }

  Future<int> clearOverviewMemberCount() async {
    final actorId = _requireAdministratorId();
    final snapshot = await _members.get();

    final documents = snapshot.docs.where((document) {
      if (document.id == actorId) {
        return false;
      }

      return MemberCountPolicy.countsInOverview(document.data());
    });

    return _removeDocumentsFromDirectory(
      documents,
      actorId: actorId,
      reason: 'Cleared from Church Overview by an administrator',
    );
  }

  Future<int> clearExplicitDemoMembers() async {
    final actorId = _requireAdministratorId();
    final snapshot = await _members.get();

    final documents = snapshot.docs.where((document) {
      if (document.id == actorId) {
        return false;
      }

      final data = document.data();
      final role = (data['role']?.toString() ?? 'member').trim();

      return MemberCountPolicy.isExplicitDemoRecord(data) &&
          MemberCountPolicy.isDirectoryVisible(data) &&
          !MemberCountPolicy.isProtectedRole(role);
    });

    return _removeDocumentsFromDirectory(
      documents,
      actorId: actorId,
      reason: 'Demo member cleared from Church Overview',
    );
  }

  String _requireAdministratorId() {
    final actorId = _auth.currentUser?.uid.trim() ?? '';

    if (actorId.isEmpty) {
      throw StateError(
        'An authenticated administrator is required to manage member counts.',
      );
    }

    return actorId;
  }

  Future<int> _removeDocumentsFromDirectory(
    Iterable<QueryDocumentSnapshot<Map<String, dynamic>>> documents, {
    required String actorId,
    required String reason,
  }) async {
    final documentList = documents.toList();
    var updatedCount = 0;

    for (var start = 0; start < documentList.length; start += _batchSize) {
      final end = (start + _batchSize) > documentList.length
          ? documentList.length
          : start + _batchSize;
      final batch = _firestore.batch();

      for (final document in documentList.sublist(start, end)) {
        batch.update(document.reference, {
          'directoryVisible': false,
          'directoryStatus': 'removed',
          'directoryRemovalReason': reason,
          'directoryRemovedAt': FieldValue.serverTimestamp(),
          'directoryRemovedBy': actorId,
          'directoryRestoredAt': FieldValue.delete(),
          'directoryRestoredBy': FieldValue.delete(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      await batch.commit();
      updatedCount += end - start;
    }

    return updatedCount;
  }
}
