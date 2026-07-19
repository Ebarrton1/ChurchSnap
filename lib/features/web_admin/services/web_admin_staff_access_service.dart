import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/auth/app_roles.dart';
import '../models/web_admin_staff_member.dart';

class WebAdminStaffAccessService {
  WebAdminStaffAccessService({
    required FirebaseFirestore firestore,
    required String churchId,
  }) : this._(firestore, churchId);

  WebAdminStaffAccessService._(this._firestore, this._churchId);

  final FirebaseFirestore _firestore;
  final String _churchId;

  CollectionReference<Map<String, dynamic>> get _members {
    return _firestore
        .collection('churches')
        .doc(_churchId)
        .collection('members');
  }

  CollectionReference<Map<String, dynamic>> get _auditLogs {
    return _firestore
        .collection('churches')
        .doc(_churchId)
        .collection('admin_audit_logs');
  }

  Stream<List<WebAdminStaffMember>> watchMembers() {
    return _members.snapshots().map((snapshot) {
      final members = snapshot.docs
          .map(
            (document) => WebAdminStaffMember.fromMap(
              id: document.id,
              data: document.data(),
            ),
          )
          .toList();

      sortMembers(members);
      return List<WebAdminStaffMember>.unmodifiable(members);
    });
  }

  Future<void> changeRole({
    required WebAdminStaffMember member,
    required String newRole,
    required String actorId,
    required String actorRole,
  }) async {
    if (actorRole != AppRoles.admin) {
      throw StateError('Only administrators may change staff roles.');
    }

    if (member.id == actorId) {
      throw StateError('Administrators cannot change their own role.');
    }

    if (!AppRoles.assignableRoles.contains(newRole)) {
      throw ArgumentError.value(newRole, 'newRole', 'Unsupported role');
    }

    if (member.role == newRole) {
      return;
    }

    final memberReference = _members.doc(member.id);
    final auditReference = _auditLogs.doc();
    final batch = _firestore.batch();

    batch.update(memberReference, {
      'role': newRole,
      'roleUpdatedAt': FieldValue.serverTimestamp(),
      'roleUpdatedBy': actorId,
    });
    batch.set(auditReference, {
      'action': 'member_role_changed',
      'actorId': actorId,
      'actorRole': actorRole,
      'targetMemberId': member.id,
      'targetDisplayName': member.displayName,
      'previousRole': member.role,
      'newRole': newRole,
      'createdAt': FieldValue.serverTimestamp(),
    });

    await batch.commit();
  }

  static void sortMembers(List<WebAdminStaffMember> members) {
    members.sort((left, right) {
      final roleComparison = roleRank(
        left.role,
      ).compareTo(roleRank(right.role));

      if (roleComparison != 0) {
        return roleComparison;
      }

      return left.displayName.toLowerCase().compareTo(
        right.displayName.toLowerCase(),
      );
    });
  }

  static int roleRank(String role) {
    return switch (role) {
      AppRoles.admin => 0,
      AppRoles.pastor => 1,
      AppRoles.ministryLeader => 2,
      AppRoles.groupLeader => 3,
      AppRoles.volunteer => 4,
      AppRoles.member => 5,
      AppRoles.visitor => 6,
      _ => 7,
    };
  }

  static int countRole(Iterable<WebAdminStaffMember> members, String role) {
    return members.where((member) => member.role == role).length;
  }
}
