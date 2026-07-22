import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/group_ministry_join_request.dart';

class GroupMinistryJoinRepository {
  GroupMinistryJoinRepository({
    FirebaseFirestore? firestore,
    required String churchId,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       churchId = churchId.trim().isEmpty ? 'demo-church' : churchId.trim();

  final FirebaseFirestore _firestore;
  final String churchId;

  DocumentReference<Map<String, dynamic>> get _church =>
      _firestore.collection('churches').doc(churchId);

  CollectionReference<Map<String, dynamic>> get _requests =>
      _church.collection('group_ministry_join_requests');

  Stream<List<GroupMinistryJoinRequest>> watchMemberRequests(String userId) {
    return _requests
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map(_mapAndSort);
  }

  Stream<List<GroupMinistryJoinRequest>> watchRequestsByType(
    String targetType,
  ) {
    return _requests
        .where('targetType', isEqualTo: targetType)
        .snapshots()
        .map(_mapAndSort);
  }

  Future<void> submitRequest({
    required String userId,
    required String memberName,
    required String targetType,
    required String targetId,
    required String targetName,
    String note = '',
  }) {
    final requestId = GroupMinistryJoinRequest.requestId(
      userId: userId,
      targetType: targetType,
      targetId: targetId,
    );

    return _requests.doc(requestId).set({
      'userId': userId,
      'memberName': memberName.trim().isEmpty
          ? 'ChurchSnap Member'
          : memberName.trim(),
      'targetType': targetType,
      'targetId': targetId,
      'targetName': targetName.trim(),
      'status': GroupMinistryJoinRequest.pendingStatus,
      'note': note.trim(),
      'createdAt': FieldValue.serverTimestamp(),
      'reviewedAt': null,
      'reviewedByUid': '',
    });
  }

  Future<void> resubmitRequest({
    required GroupMinistryJoinRequest previousRequest,
    required String memberName,
    String note = '',
  }) async {
    await removeRequest(previousRequest);

    await submitRequest(
      userId: previousRequest.userId,
      memberName: memberName,
      targetType: previousRequest.targetType,
      targetId: previousRequest.targetId,
      targetName: previousRequest.targetName,
      note: note,
    );
  }

  Future<void> removeRequest(GroupMinistryJoinRequest request) {
    return _requests.doc(request.id).delete();
  }

  Future<void> reviewRequest({
    required GroupMinistryJoinRequest request,
    required bool approve,
    required String reviewerId,
  }) {
    return _firestore.runTransaction((transaction) async {
      final requestReference = _requests.doc(request.id);
      final currentRequestSnapshot = await transaction.get(requestReference);

      if (!currentRequestSnapshot.exists) {
        throw StateError('The join request no longer exists.');
      }

      final currentRequest = GroupMinistryJoinRequest.fromMap(
        currentRequestSnapshot.id,
        currentRequestSnapshot.data() ?? const <String, dynamic>{},
      );

      if (!currentRequest.isPending) {
        throw StateError('This join request has already been reviewed.');
      }

      if (approve) {
        final targetReference = _church
            .collection(currentRequest.targetCollection)
            .doc(currentRequest.targetId);

        final targetSnapshot = await transaction.get(targetReference);

        if (!targetSnapshot.exists) {
          throw StateError('The selected group or ministry no longer exists.');
        }

        final targetData = targetSnapshot.data() ?? const <String, dynamic>{};
        final isActive =
            currentRequest.targetType == GroupMinistryJoinRequest.smallGroupType
            ? targetData['active'] != false
            : targetData['isActive'] != false;

        if (!isActive) {
          throw StateError('The selected group or ministry is inactive.');
        }

        final memberIds = List<String>.from(
          targetData['memberIds'] as List<dynamic>? ?? const <dynamic>[],
        );

        if (currentRequest.targetType ==
                GroupMinistryJoinRequest.smallGroupType &&
            !memberIds.contains(currentRequest.userId)) {
          final rawCapacity = targetData['capacity'];
          final capacity = rawCapacity is int ? rawCapacity : 12;

          if (memberIds.length >= capacity) {
            throw StateError('This small group has reached its capacity.');
          }
        }

        transaction.update(targetReference, {
          'memberIds': FieldValue.arrayUnion([currentRequest.userId]),
        });
      }

      transaction.update(requestReference, {
        'status': approve
            ? GroupMinistryJoinRequest.approvedStatus
            : GroupMinistryJoinRequest.declinedStatus,
        'reviewedAt': FieldValue.serverTimestamp(),
        'reviewedByUid': reviewerId,
      });
    });
  }

  static List<GroupMinistryJoinRequest> _mapAndSort(
    QuerySnapshot<Map<String, dynamic>> snapshot,
  ) {
    final requests = snapshot.docs
        .map(
          (document) =>
              GroupMinistryJoinRequest.fromMap(document.id, document.data()),
        )
        .toList();

    requests.sort((left, right) {
      if (left.isPending != right.isPending) {
        return left.isPending ? -1 : 1;
      }

      final leftDate = left.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      final rightDate =
          right.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);

      return rightDate.compareTo(leftDate);
    });

    return requests;
  }
}
