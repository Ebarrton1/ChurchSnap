import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/member_directory_entry.dart';

class MemberDirectoryRepository {
  MemberDirectoryRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
    required this.churchId,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final String churchId;

  CollectionReference<Map<String, dynamic>> get _members =>
      _firestore.collection('churches').doc(churchId).collection('members');

  Stream<List<MemberDirectoryEntry>> watchEntries() {
    return _members.snapshots().map((snapshot) {
      final entries = snapshot.docs
          .map(
            (document) =>
                MemberDirectoryEntry.fromMap(document.id, document.data()),
          )
          .toList();

      entries.sort((left, right) {
        final leftName = left.displayName.trim().toLowerCase();
        final rightName = right.displayName.trim().toLowerCase();

        if (leftName.isEmpty && rightName.isNotEmpty) {
          return 1;
        }

        if (rightName.isEmpty && leftName.isNotEmpty) {
          return -1;
        }

        final nameComparison = leftName.compareTo(rightName);

        if (nameComparison != 0) {
          return nameComparison;
        }

        return left.email.toLowerCase().compareTo(right.email.toLowerCase());
      });

      return List<MemberDirectoryEntry>.unmodifiable(entries);
    });
  }

  Future<void> removeFromDirectory({
    required String memberId,
    String reason = '',
  }) {
    return _setDirectoryVisibility(
      memberId: memberId,
      visible: false,
      reason: reason,
    );
  }

  Future<void> restoreToDirectory({required String memberId}) {
    return _setDirectoryVisibility(memberId: memberId, visible: true);
  }

  Future<void> _setDirectoryVisibility({
    required String memberId,
    required bool visible,
    String reason = '',
  }) async {
    final normalizedMemberId = memberId.trim();
    final actorId = _auth.currentUser?.uid.trim() ?? '';

    if (normalizedMemberId.isEmpty) {
      throw ArgumentError.value(memberId, 'memberId', 'Member ID is required.');
    }

    if (actorId.isEmpty) {
      throw StateError(
        'An authenticated administrator is required to manage the directory.',
      );
    }

    if (actorId == normalizedMemberId) {
      throw StateError(
        'For safety, administrators cannot change their own directory status.',
      );
    }

    final reference = _members.doc(normalizedMemberId);
    final snapshot = await reference.get();

    if (!snapshot.exists) {
      throw StateError('The selected member record no longer exists.');
    }

    if (visible) {
      await reference.update({
        'directoryVisible': true,
        'directoryStatus': 'visible',
        'directoryRemovalReason': FieldValue.delete(),
        'directoryRemovedAt': FieldValue.delete(),
        'directoryRemovedBy': FieldValue.delete(),
        'directoryRestoredAt': FieldValue.serverTimestamp(),
        'directoryRestoredBy': actorId,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return;
    }

    await reference.update({
      'directoryVisible': false,
      'directoryStatus': 'removed',
      'directoryRemovalReason': reason.trim(),
      'directoryRemovedAt': FieldValue.serverTimestamp(),
      'directoryRemovedBy': actorId,
      'directoryRestoredAt': FieldValue.delete(),
      'directoryRestoredBy': FieldValue.delete(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
