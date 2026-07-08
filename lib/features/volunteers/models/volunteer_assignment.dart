import 'package:cloud_firestore/cloud_firestore.dart';

class VolunteerAssignment {
  final String id;
  final String ministryId;
  final String ministryName;
  final String memberId;
  final String memberName;
  final String role;
  final DateTime? servingDate;
  final String status;

  const VolunteerAssignment({
    this.id = '',
    required this.ministryId,
    required this.ministryName,
    required this.memberId,
    required this.memberName,
    this.role = 'Volunteer',
    this.servingDate,
    this.status = 'scheduled',
  });

  factory VolunteerAssignment.fromMap(String id, Map<String, dynamic> map) {
    return VolunteerAssignment(
      id: id,
      ministryId: map['ministryId'] ?? '',
      ministryName: map['ministryName'] ?? '',
      memberId: map['memberId'] ?? '',
      memberName: map['memberName'] ?? '',
      role: map['role'] ?? 'Volunteer',
      servingDate: (map['servingDate'] as Timestamp?)?.toDate(),
      status: map['status'] ?? 'scheduled',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'ministryId': ministryId,
      'ministryName': ministryName,
      'memberId': memberId,
      'memberName': memberName,
      'role': role,
      'servingDate': servingDate == null
          ? null
          : Timestamp.fromDate(servingDate!),
      'status': status,
    };
  }
}
