import 'package:cloud_firestore/cloud_firestore.dart';

class GroupMinistryJoinRequest {
  const GroupMinistryJoinRequest({
    required this.id,
    required this.userId,
    required this.memberName,
    required this.targetType,
    required this.targetId,
    required this.targetName,
    required this.status,
    required this.note,
    this.createdAt,
    this.reviewedAt,
    this.reviewedByUid = '',
  });

  static const ministryType = 'ministry';
  static const smallGroupType = 'smallGroup';

  static const pendingStatus = 'pending';
  static const approvedStatus = 'approved';
  static const declinedStatus = 'declined';

  final String id;
  final String userId;
  final String memberName;
  final String targetType;
  final String targetId;
  final String targetName;
  final String status;
  final String note;
  final DateTime? createdAt;
  final DateTime? reviewedAt;
  final String reviewedByUid;

  bool get isPending => status == pendingStatus;
  bool get isApproved => status == approvedStatus;
  bool get isDeclined => status == declinedStatus;

  String get targetTypeLabel {
    return targetType == smallGroupType ? 'Small Group' : 'Ministry';
  }

  String get targetCollection {
    return targetType == smallGroupType ? 'small_groups' : 'ministries';
  }

  String get targetKey => '$targetType:$targetId';

  factory GroupMinistryJoinRequest.fromMap(
    String id,
    Map<String, dynamic> map,
  ) {
    return GroupMinistryJoinRequest(
      id: id,
      userId: _stringValue(map['userId']),
      memberName: _stringValue(map['memberName']),
      targetType: _stringValue(map['targetType']),
      targetId: _stringValue(map['targetId']),
      targetName: _stringValue(map['targetName']),
      status: _stringValue(map['status']),
      note: _stringValue(map['note']),
      createdAt: _dateValue(map['createdAt']),
      reviewedAt: _dateValue(map['reviewedAt']),
      reviewedByUid: _stringValue(map['reviewedByUid']),
    );
  }

  static String requestId({
    required String userId,
    required String targetType,
    required String targetId,
  }) {
    return '${targetType}__${targetId}__$userId';
  }

  static String _stringValue(dynamic value) {
    return value is String ? value.trim() : '';
  }

  static DateTime? _dateValue(dynamic value) {
    return value is Timestamp ? value.toDate() : null;
  }
}
