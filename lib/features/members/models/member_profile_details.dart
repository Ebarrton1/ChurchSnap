import 'package:cloud_firestore/cloud_firestore.dart';

class MemberProfileDetails {
  const MemberProfileDetails({
    this.dateOfBirth,
    this.maritalStatus = '',
    this.gender = '',
  });

  final DateTime? dateOfBirth;
  final String maritalStatus;
  final String gender;

  bool get isEmpty =>
      dateOfBirth == null &&
      maritalStatus.trim().isEmpty &&
      gender.trim().isEmpty;

  factory MemberProfileDetails.fromMap(Map<String, dynamic> map) {
    return MemberProfileDetails(
      dateOfBirth: _dateFromValue(map['dateOfBirth']),
      maritalStatus: map['maritalStatus'] as String? ?? '',
      gender: map['gender'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    final normalizedDate = dateOfBirth == null
        ? null
        : DateTime(dateOfBirth!.year, dateOfBirth!.month, dateOfBirth!.day);

    return {
      'dateOfBirth': normalizedDate == null
          ? null
          : Timestamp.fromDate(normalizedDate),
      'maritalStatus': maritalStatus.trim(),
      'gender': gender.trim(),
    };
  }
}

DateTime? _dateFromValue(Object? value) {
  if (value is Timestamp) {
    return value.toDate();
  }

  if (value is DateTime) {
    return value;
  }

  return null;
}
